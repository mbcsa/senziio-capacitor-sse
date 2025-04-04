import { WebPlugin } from '@capacitor/core';
import type { SenziioSSEPlugin, SSEEvent } from './definitions';

export class SenziioSSEWeb extends WebPlugin implements SenziioSSEPlugin {
  private eventSource: EventSource | null = null;
  
  // Usa el tipo correcto para listeners heredado de WebPlugin
  private sseListeners: ((event: SSEEvent) => void)[] = [];

  async connect(options: { url: string }): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        this.eventSource = new EventSource(options.url);

        this.eventSource.onmessage = (event) => {
          const sseEvent: SSEEvent = {
            type: 'message',
            data: event.data
          };
          
          // Notificar a los listeners registrados
          this.sseListeners.forEach(listener => listener(sseEvent));
        };

        this.eventSource.onerror = (error) => {
          reject(new Error(`SSE Error: ${error}`));
          this.disconnect();
        };

        resolve();
      } catch (error) {
        reject(new Error(`Failed to connect: ${error}`));
      }
    });
  }

  async disconnect(): Promise<void> {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
    this.sseListeners = [];
  }

  async addListener(
    eventName: 'sseEvent',  // <-- Se declara pero no se usa
    listenerFunc: (event: SSEEvent) => void,
  ) {
    // Verifica el nombre del evento (elimina TS6133 y agrega seguridad)
    if (eventName !== 'sseEvent') {
      throw new Error('Solo se admite el evento "sseEvent"');
    }
  
    this.sseListeners.push(listenerFunc);
    
    return {
      remove: async () => {
        this.sseListeners = this.sseListeners.filter(
          listener => listener !== listenerFunc
        );
      }
    };
  }

  async removeAllListeners() {
    this.sseListeners = [];
  }
}