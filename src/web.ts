import { WebPlugin } from '@capacitor/core';

import type { SenziioSSEPlugin } from './definitions';

export class SenziioSSEWeb extends WebPlugin implements SenziioSSEPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
