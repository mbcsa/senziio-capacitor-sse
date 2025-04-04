import type { PluginListenerHandle } from '@capacitor/core';

export interface SenziioSSEPlugin {
  // Métodos principales
  connect(options: { url: string }): Promise<void>;
  disconnect(): Promise<void>;

  // Listeners para eventos
  addListener(
    eventName: 'sseEvent',
    listenerFunc: (event: SSEEvent) => void,
  ): Promise<PluginListenerHandle>;

  removeAllListeners(): Promise<void>;
}

export interface SSEEvent {
  type: string;
  data: string;
}