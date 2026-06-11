import { defineConfig } from "cypress";

export default defineConfig({
  allowCypressEnv: false,

  e2e: {
    baseUrl: 'http://127.0.0.1:9292',
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
