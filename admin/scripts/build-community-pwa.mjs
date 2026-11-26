import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, rmSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const adminRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repositoryRoot = path.resolve(adminRoot, '..');
const flutterRoot = path.join(repositoryRoot, 'frontend');
const webOutput = path.join(flutterRoot, 'build', 'web');
const publicRoot = path.join(adminRoot, 'public');
const communityOutput = path.join(publicRoot, 'community');
const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

const env = { ...process.env, API_URL: apiUrl, BASE_HREF: '/community/' };
let result;
if (process.platform === 'win32') {
  const builtIndex = path.join(webOutput, 'index.html');
  if (!existsSync(builtIndex) || !readFileSync(builtIndex, 'utf8').includes('<base href="/community/">')) {
    throw new Error('On Windows, first run flutter build web --release --base-href /community/ from frontend.');
  }
  console.log('Using the existing Windows Flutter web build.');
  result = { status: 0 };
} else {
  result = spawnSync('bash', [path.join(flutterRoot, 'build-web.sh')], {
    cwd: flutterRoot,
    stdio: 'inherit',
    env,
  });
}

if (result.error) throw result.error;
if (result.status !== 0) process.exit(result.status ?? 1);

const resolvedOutput = path.resolve(communityOutput);
if (!resolvedOutput.startsWith(`${path.resolve(publicRoot)}${path.sep}`)) {
  throw new Error('Refusing to write the Flutter output outside admin/public.');
}

rmSync(resolvedOutput, { recursive: true, force: true });
mkdirSync(path.dirname(resolvedOutput), { recursive: true });
cpSync(webOutput, resolvedOutput, { recursive: true });
console.log('Flutter community PWA copied to admin/public/community.');
