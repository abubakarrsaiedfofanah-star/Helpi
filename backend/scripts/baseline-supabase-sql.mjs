import { spawnSync } from 'node:child_process';
import { readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const backendRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const prismaCli = path.join(backendRoot, 'node_modules', 'prisma', 'build', 'index.js');
const migrationsRoot = path.join(backendRoot, 'prisma', 'migrations');
const migrations = readdirSync(migrationsRoot)
  .filter((name) => statSync(path.join(migrationsRoot, name)).isDirectory())
  .sort();

if (!migrations.length) throw new Error('No Prisma migrations were found.');

for (const migration of migrations) {
  console.log(`Recording ${migration} as already applied...`);
  const result = spawnSync(process.execPath, [
    prismaCli, 'migrate', 'resolve', '--applied', migration,
  ], { cwd: backendRoot, stdio: 'inherit', env: process.env });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

const metadataRls = spawnSync(process.execPath, [prismaCli, 'db', 'execute', '--stdin'], {
  cwd: backendRoot,
  input: 'ALTER TABLE IF EXISTS public."_prisma_migrations" ENABLE ROW LEVEL SECURITY;',
  stdio: ['pipe', 'inherit', 'inherit'],
  env: process.env,
  encoding: 'utf8',
});
if (metadataRls.error) throw metadataRls.error;
if (metadataRls.status !== 0) process.exit(metadataRls.status ?? 1);

console.log('Baseline complete. Run npm run db:status, then npm run db:setup for future deployments.');
