const fs = require('fs');
const path = require('path');

const cfgPath = path.join(__dirname, 'screens.json');
let cfg = { port: 8080 };
try {
  const raw = fs.readFileSync(cfgPath, 'utf8');
  cfg = JSON.parse(raw);
} catch (e) {
  console.log('Warning: could not read screens.json, using defaults', e.message || e);
}

const PORT = process.env.PORT ? Number(process.env.PORT) : (cfg.port || 8080);

module.exports = {
  PORT,
  cfg,
};
