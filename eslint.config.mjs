import { defineConfig, globalIgnores } from "eslint/config";
import astro from "eslint-plugin-astro";

const eslintConfig = defineConfig([
  ...astro.configs.recommended,
  globalIgnores([
    "dist/**",
    ".astro/**",
    "node_modules/**",
  ]),
]);

export default eslintConfig;
