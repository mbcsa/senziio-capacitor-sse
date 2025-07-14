// web.ts
import { WebPlugin } from '@capacitor/core';
import { ConnectionEventCallback, ConnectionID, SenziioSSEPlugin } from './definitions';

export class SenziioSSEWeb extends WebPlugin implements SenziioSSEPlugin {
  private readonly connections = new Map<ConnectionID, EventSource>();
  private sequence = 1;

  async connect(options: { url: string }, callback: ConnectionEventCallback): Promise<ConnectionID> {
    const connectionId = String(this.sequence++);

    const eventSource = new EventSource(options.url);

    eventSource.onmessage = async (event) => {
      let payload: any;

      try {
        payload = JSON.parse(event.data);
      } catch (error) {
        console.error('Error parsing event:', event);
        return;
      }

      await callback({ type: 'message', payload });
    };

    eventSource.onopen = async () => {
      await callback({ type: 'status', status: 'connected' });
    };

    eventSource.onerror = async (error) => {
      await callback(undefined, error);
      await this.disconnect({ connectionId });
    };

    this.connections.set(connectionId, eventSource);

    return connectionId;
  }

  async disconnect({ connectionId }: { connectionId: ConnectionID }): Promise<void> {
    if (!this.connections.has(connectionId)) {
      throw new Error('ID erróneo: ' + connectionId);
    }

    const connection = this.connections.get(connectionId)!;
    connection.close();
  }
}