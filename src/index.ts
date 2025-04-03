import { registerPlugin } from '@capacitor/core';

import type { SenziioSSEPlugin } from './definitions';

const SenziioSSE = registerPlugin<SenziioSSEPlugin>('SenziioSSE', {
  web: () => import('./web').then((m) => new m.SenziioSSEWeb()),
});

export * from './definitions';
export { SenziioSSE };
