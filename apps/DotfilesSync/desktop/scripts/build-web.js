const { spawnSync } = require('child_process');
const path = require('path');

const command = process.platform === 'win32' ? 'yarn.cmd' : 'yarn';
const result = spawnSync(command, ['web:build'], {
  cwd: path.resolve(__dirname, '..'),
  env: { ...process.env, STAGE: 'production' },
  shell: process.platform === 'win32',
  stdio: 'inherit',
});

if (result.error) {
  console.error(`Could not run the web build: ${result.error.message}`);
  process.exit(1);
}

process.exit(result.status ?? 1);
