import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const backendRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const prismaCli = path.join(backendRoot, 'node_modules', 'prisma', 'build', 'index.js');
const schemaPath = path.join(backendRoot, 'prisma', 'schema.prisma');
const countriesPath = path.join(backendRoot, 'data', 'countries.json');
const outputPath = path.join(backendRoot, 'supabase', 'helpi_complete_schema.sql');
const partsRoot = path.join(backendRoot, 'supabase', 'parts');

const diff = spawnSync(process.execPath, [
  prismaCli,
  'migrate', 'diff',
  '--from-empty',
  '--to-schema-datamodel', schemaPath,
  '--script',
], { cwd: backendRoot, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024, env: { ...process.env, NO_COLOR: '1' } });

if (diff.error) throw diff.error;
if (diff.status !== 0) {
  process.stderr.write(diff.stderr || 'Prisma could not generate the Supabase schema.\n');
  process.exit(diff.status ?? 1);
}

const countries = JSON.parse(readFileSync(countriesPath, 'utf8'));
const codes = new Set();
const sqlString = (value) => `'${String(value).replaceAll("'", "''")}'`;
const jsonb = (value) => `${sqlString(JSON.stringify(value))}::jsonb`;

const defaults = {
  languages: ['en'],
  paymentMethods: [],
  kycRequirements: { identityRequired: true, acceptedDocumentTypes: [] },
  kybRequirements: { enabled: true, requiredForOrganizations: true, documents: [] },
  safeguardingRules: { childSafetyReview: true, exactAddressesPublic: false, escalationRequired: true },
  emergencyResources: [],
  documentTypes: [],
  dataRetention: { identityDays: 2555, caseDays: 2555, financialDays: 2555, deletionRequestWorkflow: true },
  helpMethods: ['MONEY', 'GOODS', 'SKILLS', 'TIME', 'TRANSPORT', 'SERVICES'],
  verificationRules: { identity: true, need: true, institution: true, paymentDestination: true, humanReview: true },
  communicationRules: { translation: true, voice: true, video: true, childContactRequiresSafeguards: true },
};

const countryRows = countries.map((country) => {
  if (!/^[A-Z]{2}$/.test(country.code) || codes.has(country.code)) {
    throw new Error(`Invalid or duplicate country registry entry: ${country.code}`);
  }
  codes.add(country.code);
  if (country.currency != null && typeof country.currency !== 'string') {
    throw new Error(`Invalid currency for country ${country.code}`);
  }
  return `  (${sqlString(country.code)}, ${country.currency ? sqlString(country.currency) : 'NULL'})`;
}).join(',\n');

const header = `-- Helpi Supabase bootstrap SQL
-- Generated from prisma/schema.prisma and data/countries.json.
-- Run once in the SQL Editor of a NEW Supabase project.
-- Do not run this over an existing Helpi database; use Prisma migrations for upgrades.
-- RLS is enabled on all application tables with no client policies. The NestJS API must
-- use the private Supabase Postgres connection as the database owner/service role.

BEGIN;

`;

const countrySeed = `
-- Initial country settings used by the app and admin country-operations screens.
INSERT INTO "CountryConfiguration" (
  "id", "countryCode", "enabled", "defaultLanguage", "languages", "currencies",
  "paymentMethods", "kycRequirements", "kybRequirements", "safeguardingRules",
  "emergencyResources", "documentTypes", "dataRetention", "helpMethods",
  "verificationRules", "communicationRules", "updatedById", "createdAt", "updatedAt"
) SELECT
  'country-' || country.code, country.code, TRUE, 'en',
  ${jsonb(defaults.languages)},
  CASE WHEN country.currency IS NULL THEN '[]'::jsonb ELSE jsonb_build_array(country.currency) END,
  ${jsonb(defaults.paymentMethods)},
  ${jsonb(defaults.kycRequirements)},
  ${jsonb(defaults.kybRequirements)},
  ${jsonb(defaults.safeguardingRules)},
  ${jsonb(defaults.emergencyResources)},
  ${jsonb(defaults.documentTypes)},
  ${jsonb(defaults.dataRetention)},
  ${jsonb(defaults.helpMethods)},
  ${jsonb(defaults.verificationRules)},
  ${jsonb(defaults.communicationRules)},
  NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
${countryRows}
) AS country(code, currency)
ON CONFLICT ("countryCode") DO UPDATE SET "currencies" = EXCLUDED."currencies";

`;

const rls = `
-- Keep the public Supabase Data API closed to anonymous/authenticated client roles.
-- The API server connects as the database owner and performs authorization itself.
DO $helpi_enable_rls$
DECLARE
  target RECORD;
BEGIN
  FOR target IN
    SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', 'public', target.tablename);
  END LOOP;
END;
$helpi_enable_rls$;

COMMIT;
`;

const normalizedEmailIndex = `-- Enforce one account per email regardless of casing or surrounding whitespace.
CREATE UNIQUE INDEX "User_email_normalized_key" ON "User" (LOWER(BTRIM("email")));`;
const generatedDdl = `${diff.stdout.trim()}\n\n${normalizedEmailIndex}`;
const output = header + generatedDdl + '\n\n' + countrySeed + rls;
mkdirSync(path.dirname(outputPath), { recursive: true });
writeFileSync(outputPath, output, 'utf8');

// The Supabase SQL Editor can truncate large pasted queries. Split the Prisma DDL
// only at completed statement boundaries and keep every editor-ready part small.
const statements = [];
let pendingStatementLines = [];
for (const line of generatedDdl.split(/\r?\n/)) {
  pendingStatementLines.push(line);
  if (line.trimEnd().endsWith(';')) {
    statements.push(pendingStatementLines.join('\n'));
    pendingStatementLines = [];
  }
}
if (pendingStatementLines.length) statements.push(pendingStatementLines.join('\n'));

const maxPartBytes = 15_000;
const ddlChunks = [];
let currentChunk = [];
let currentBytes = 0;
for (const statement of statements) {
  const statementBytes = Buffer.byteLength(statement, 'utf8') + 1;
  if (currentChunk.length && currentBytes + statementBytes > maxPartBytes) {
    ddlChunks.push(currentChunk.join('\n\n'));
    currentChunk = [];
    currentBytes = 0;
  }
  currentChunk.push(statement);
  currentBytes += statementBytes;
}
if (currentChunk.length) ddlChunks.push(currentChunk.join('\n\n'));

const partCount = ddlChunks.length;
mkdirSync(partsRoot, { recursive: true });
for (let index = 0; index < partCount; index += 1) {
  const isLast = index === partCount - 1;
  const content = [
    `-- Helpi Supabase setup, part ${index + 1} of ${partCount}. Run parts in order.`,
    '-- Run each part once in a NEW project. If a part fails, fix that part before continuing.',
    'BEGIN;',
    ddlChunks[index],
    isLast ? countrySeed.trim() : '',
    isLast ? rls.trim().replace(/\nCOMMIT;\s*$/, '') : '',
    'COMMIT;',
    '',
  ].filter(Boolean).join('\n\n');
  const partPath = path.join(partsRoot, `helpi_schema_part_${index + 1}.sql`);
  writeFileSync(partPath, content, 'utf8');
  console.log(`Wrote ${path.relative(backendRoot, partPath)} (${Buffer.byteLength(content, 'utf8')} bytes).`);
}
console.log(`Wrote ${path.relative(backendRoot, outputPath)} (${countries.length} country defaults).`);
