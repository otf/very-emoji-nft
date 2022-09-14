import { test, expect } from '@playwright/test';

test('web has h1', async ({ page }) => {
  await page.goto('http://localhost:8000/');

  const h1 = page.locator('h1');

  await expect(h1).toHaveText('Hello Elm');
});
