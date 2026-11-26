import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const adminRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repositoryRoot = path.resolve(adminRoot, '..');
const communityRoot = path.join(repositoryRoot, 'user-app');
const webOutput = path.join(communityRoot, 'dist');
const publicRoot = path.join(adminRoot, 'public');
const communityOutput = path.join(publicRoot, 'community');
const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm';
const env = {
  ...process.env,
  EXPO_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || process.env.EXPO_PUBLIC_API_URL || '',
  EXPO_PUBLIC_ADMIN_PORTAL_URL: process.env.NEXT_PUBLIC_ADMIN_PORTAL_URL || 'https://helpi-eight.vercel.app',
};

function run(command, args, cwd) {
  const result = spawnSync(command, args, {
    cwd,
    stdio: 'inherit',
    env,
    shell: process.platform === 'win32',
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

if (!existsSync(path.join(communityRoot, 'package-lock.json'))) {
  throw new Error('The Expo app is missing package-lock.json. Run npm install in user-app and commit its lock file.');
}

run(npm, ['ci', '--include=dev'], communityRoot);
run(npm, ['exec', '--', 'expo', 'export', '--platform', 'web', '--output-dir', 'dist'], communityRoot);

const exportedIndex = path.join(webOutput, 'index.html');
if (!existsSync(exportedIndex)) throw new Error('Expo did not produce dist/index.html.');
const html = readFileSync(exportedIndex, 'utf8');
if (!html.includes('rel="manifest"')) {
  writeFileSync(exportedIndex, html.replace('</head>', '<link rel="manifest" href="/community/manifest.json"><meta name="theme-color" content="#10213d"></head>'));
}

const resolvedOutput = path.resolve(communityOutput);
if (!resolvedOutput.startsWith(`${path.resolve(publicRoot)}${path.sep}`)) {
  throw new Error('Refusing to write the Flutter output outside admin/public.');
}

rmSync(resolvedOutput, { recursive: true, force: true });
mkdirSync(path.dirname(resolvedOutput), { recursive: true });
cpSync(webOutput, resolvedOutput, { recursive: true });
console.log('Expo community PWA copied to admin/public/community.');
