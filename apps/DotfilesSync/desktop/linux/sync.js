const fs = require('fs');
const path = require('path');

const source = path.resolve(__dirname, '../.dist');
const destination = path.join(__dirname, 'app');

if (!fs.existsSync(source)) {
  throw new Error(`Web build not found: ${source}`);
}

fs.rmSync(destination, { recursive: true, force: true });
fs.cpSync(source, destination, { recursive: true });
