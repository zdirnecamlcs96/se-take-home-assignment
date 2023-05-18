const { test, expect } = require('@playwright/test');


// See here how to get started:
// https://playwright.dev/docs/intro
test('visits the app root url', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('div.greetings > h1')).toHaveText('Welcome');
})

test('visits the cooking bot', async ({ page, mount }) => {
  await page.goto('/bot');
  test('add bot', async ({ page, mount }) => {
    await page.goto('/bot');

    const buttonText = '+ Bot';

    (await page.waitForSelector(`button:has-text("${buttonText}")`)).click();

    await expect(page.locator('div.bot')).toHaveText('Cooking Bot');
  })
})
