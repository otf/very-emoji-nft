import { test, expect } from '@playwright/test';

test('web has logo', async ({ page }) => {
  await page.goto('http://localhost:8000/');

  const h1 = page.locator('h1 img');

  await expect(h1).toHaveAttribute('alt', 'Very Emoji');
});
