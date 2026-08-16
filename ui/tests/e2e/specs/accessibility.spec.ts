import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";
import { BASE_URL } from "./constants";

const pagesToTest = [
  "/",
  "/apps",
  "/pkgs",
  "/recipe",
  "/recipe/options",
];

test.describe("Color Contrast Accessibility", () => {
  for (const pagePath of pagesToTest) {
    for (const colorScheme of ["light", "dark"] as const) {
      test(`should have sufficient color contrast on ${pagePath} in ${colorScheme} mode`, async ({ page }) => {
        await page.emulateMedia({ colorScheme });
        await page.goto(`${BASE_URL}${pagePath}`);

        // Wait for the Elm app to mount
        await page.locator(".min-vh-100").waitFor();

        const accessibilityScanResults = await new AxeBuilder({ page })
          .withRules(["color-contrast"])
          .analyze();

        if (accessibilityScanResults.violations.length > 0) {
          console.error(`Violations on ${pagePath} in ${colorScheme} mode:`);
          for (const v of accessibilityScanResults.violations) {
            console.error(v.help);
            for (const node of v.nodes) {
              console.error(node.failureSummary);
              console.error(node.html);
            }
          }
        }

        expect(accessibilityScanResults.violations).toEqual([]);
      });
    }
  }
});
