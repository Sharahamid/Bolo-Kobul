// Browser tests for Bolo Kobul. They create and change data, so they must only ever
// run against a local or staging copy of the site - never the live website.
const { defineConfig, devices } = require('@playwright/test');

const baseURL = process.env.E2E_BASE_URL || 'http://127.0.0.1:3000';
if (/bolokobul\.com/i.test(baseURL)) {
  throw new Error(`Refusing to run browser tests against the live site (${baseURL})`);
}

module.exports = defineConfig({
  testDir: './tests',
  globalSetup: require.resolve('./support/global-setup.js'),
  fullyParallel: false,
  workers: 1, // tests share one database
  retries: 0,
  timeout: 90_000,
  expect: { timeout: 15_000 },
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'playwright-report' }]],
  use: {
    baseURL,
    ...devices['Desktop Chrome'],
    viewport: { width: 1366, height: 900 },
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    ignoreHTTPSErrors: true // the local stand-in for aamarPay uses a self-made test certificate
  }
});
