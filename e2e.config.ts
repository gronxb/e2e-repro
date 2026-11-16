import type { E2EConfig } from 'e2e';
import { mobile } from '@e2e-dev/mobile';

export default {
  projectId: 'repro.tap-window-origin',
  tests: 'tests/**/*.e2e.ts',
  targets: [
    {
      name: 'ios',
      engine: mobile({ platform: 'ios', session: 'e2e-repro-tap', ...(process.env.REPRO_DEVICE ? { device: process.env.REPRO_DEVICE } : {}) }),
      app: { bundleId: 'dev.e2e.repro.taporigin' },
    },
  ],
  video: 'off',
  workers: 1,
  retries: 0,
  reporters: ['list'],
} satisfies E2EConfig;
