// web.ts
import { PluginListenerHandle, WebPlugin, ListenerCallback } from '@capacitor/core';
import {
  SenziioSSEPlugin,
  EventType,
  EventDataMap,
  eventNames
} from './definitions';

export class SenziioSSEWeb extends WebPlugin implements SenziioSSEPlugin {
  private eventSource: EventSource | null = null;
  listeners: { [eventName: string]: ListenerCallback[] } = {}; // Ajustamos la definición

  async connect(options: { url: string }): Promise<void> {
    try {
      this.eventSource = new EventSource(options.url);

      this.eventSource.onmessage = (event) => {
        try {
          const parsedData = JSON.parse(event.data);
          this.handleEvent(parsedData.type as EventType, parsedData.data);
        } catch (error) {
          console.error('Error parsing event:', error);
          this.handleEvent('error', { message: 'Error parsing event data' });
        }
      };

      this.eventSource.onopen = () => {
        this.handleEvent('connected', { status: 'connected' });
      };

      this.eventSource.onerror = (error) => {
        console.error('SSE Error:', error);
        this.handleEvent('connection_error', { 
          message: 'SSE connection error',
          error: error 
        });
        this.handleEvent('disconnected', { 
          status: 'disconnected',
          reason: 'error' 
        });
        this.disconnect();
      };

    } catch (error) {
      console.error('Connection setup error:', error);
      this.handleEvent('connection_error', { 
        message: 'Failed to setup SSE connection',
        error: error 
      });
      throw error;
    }
  }

  private handleEvent<T extends EventType>(type: T, data: EventDataMap[T]) {
    const eventListeners = this.listeners[type] as ((event: EventDataMap[T]) => void)[] | undefined;
    if (eventListeners) {
      eventListeners.forEach(listener => listener(data));
    }
  }

  async addListener<T extends EventType>(
    eventName: T,
    listenerFunc: (event: EventDataMap[T]) => void
  ): Promise<PluginListenerHandle> {
    if (!eventNames.includes(eventName)) {
      throw new Error(`Evento no válido: ${eventName}`);
    }

    const typedListenerFunc: ListenerCallback = (data: any) => {
      listenerFunc(data as EventDataMap[T]);
    };

    if (!this.listeners[eventName]) {
      this.listeners[eventName] = [];
    }

    this.listeners[eventName].push(typedListenerFunc);

    return {
      remove: async () => {
        this.listeners[eventName] = this.listeners[eventName]?.filter(
          listener => listener !== typedListenerFunc
        );
      }
    };
  }

  async disconnect(): Promise<void> {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
    this.listeners = {};
  }

  async removeAllListeners(eventName?: EventType): Promise<void> {
    if (eventName) {
      delete this.listeners[eventName];
    } else {
      this.listeners = {};
    }
  }
}