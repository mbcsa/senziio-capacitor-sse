// web.ts
import { WebPlugin } from '@capacitor/core';
import { ConnectionEventCallback, ConnectionID, MessagePayload, SenziioSSEPlugin } from './definitions';

export class SenziioSSEWeb extends WebPlugin implements SenziioSSEPlugin {
  private readonly connections = new Map<ConnectionID, EventSource>();
  private sequence = 1;

  async connect(options: { url: string }, callback: ConnectionEventCallback): Promise<ConnectionID> {
    const connectionId = String(this.sequence++);
    
    const eventSource = new EventSource(options.url, { withCredentials: true });

    const knownEventTypes = [
        'ComunicationStatusEvent',
        'IlluminanceReadEvent',
        'PresenceChangeEvent',
        'SensorsReadEvent',
        'ThermalImageCaptureEvent',
        'BeaconEvent',
        'RadarEvent',
        'StatusEvent',
        'ConnectedEvent',
        'BeaconListEvent',
        'InfoNetworkEvent',
        
    ];

    const namedEventHandler = (event: Event) => {
      const messageEvent = event as MessageEvent;
      
      console.log(`[SSE Plugin Web] Evento recibido -> Nombre: ${messageEvent.type}, Datos: ${messageEvent.data}`);
      
      const payload: MessagePayload = {
        type: messageEvent.type,
        data: messageEvent.data,
      };

      /**
       * CORRECCIÓN FINAL: Se invoca el callback y se guarda el resultado.
       * Luego, se comprueba si el resultado es una promesa (si tiene un método 'then').
       * Solo si es una promesa, se le añade el manejador .catch().
       */
      const result = callback({ type: 'message', payload: payload });
      if (result && typeof result.then === 'function') {
          result.catch(err => {
              console.error('[SSE Plugin Web] Error al ejecutar el callback del cliente:', err);
          });
      }
    };

    knownEventTypes.forEach(eventType => {
      eventSource.addEventListener(eventType, namedEventHandler);
    });

    eventSource.onopen = async () => {
      console.log('[SSE Plugin Web] Conexión abierta.');
      await callback({ type: 'status', status: 'connected' });
    };

    eventSource.onerror = async (error) => {
      console.error('[SSE Plugin Web] Error en EventSource:', error);
      const promise = callback(undefined, { message: 'Connection Error', data: error });
      if (promise && typeof promise.then === 'function') {
        await promise;
      }
      this.disconnect({ connectionId });
    };
    
    this.connections.set(connectionId, eventSource);
    return connectionId;
  }

  async disconnect({ connectionId }: { connectionId: ConnectionID }): Promise<void> {
    const connection = this.connections.get(connectionId);
    if (connection) {
      connection.close();
      this.connections.delete(connectionId);
      console.log(`[SSE Plugin Web] Conexión cerrada: ${connectionId}`);
    } else {
      console.warn(`[SSE Plugin Web] Se intentó desconectar una conexión no existente o ya cerrada: ${connectionId}`);
    }
  }
}