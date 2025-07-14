
export type ConnectionID = string;

export type MessagePayload = { type: string, data: string };

export type MessageConnectionEvent = { type: 'message', payload: MessagePayload };
export type StatusConnectionEvent = { type: 'status', status: 'connected'|'disconnected' };

export type ConnectionEvent = MessageConnectionEvent|StatusConnectionEvent;
export type ConnectionError = { message: string, code: string|null, data?: any };

export type ConnectionEventCallback = ((event?: ConnectionEvent, err?: any) => Promise<void>|void);

// Tipo general para el plugin
export interface SenziioSSEPlugin {
  connect(options: { url: string }, callback: ConnectionEventCallback): Promise<ConnectionID>;
  disconnect(options: { connectionId: ConnectionID }): Promise<void>;
}
