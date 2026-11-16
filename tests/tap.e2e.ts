import { expect, test } from 'e2e';

// Each reload loads a heavy page into the web view; right after it, the
// snapshot can come back without the window's screen origin.
test('locator.tap right after the web view loads', async ({ app, screen }) => {
  await app.open();
  for (let taps = 1; taps <= 3; taps++) {
    await screen.getByTestId('reload-web').tap();
    await screen.getByTestId('tap-me').tap();
    await expect(screen.getByTestId('tap-count')).toHaveText(`Taps: ${taps}`, { timeout: 30_000 });
  }
});
