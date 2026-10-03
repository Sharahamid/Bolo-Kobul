// Resets the test members before each run and records their details for the tests.
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

module.exports = async () => {
  const repoRoot = path.resolve(__dirname, '..', '..');
  const seedCommand = process.env.E2E_SEED_COMMAND || 'bundle exec rails runner e2e/support/seed.rb';
  const output = execSync(seedCommand, { cwd: repoRoot, encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] });
  const json = output.trim().split('\n').reverse().find((line) => line.trim().startsWith('{'));
  if (!json) throw new Error(`Seed script did not print test data:\n${output}`);
  fs.writeFileSync(path.join(__dirname, '.seed.json'), json);
};
