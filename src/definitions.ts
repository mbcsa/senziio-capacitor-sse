import type { PluginListenerHandle } from '@capacitor/core';

// Definir tipos de eventos y sus estructuras de datos
export interface ComunicationStatusEvent {
  mqtt: {
    enable: boolean;
    host: string;
    normal_mqtt_port: string;
    state: string;
  }
  network: {
      ethIP: string;
      signal: string;
      ssid: string;
      state: string;
      wifiIPAddr: string;
      wifiMode: string;
  }
}

export interface IlluminanceReadEvent {
  light_level: string;
}

export interface SensorsReadEvent {
  airQuality: {
    co2: string,
    humidity: string,
    temperature: string
  }
}

export interface PresenceChangeEvent {
  b:string,
  c: string,
  count_person: string,
  p: string,
  r:number,
  x:string,
  y:string,
}

export interface ThermalImageCaptureEvent {
  detectedPixels: number;
  diffFrame15: number[][];
  diffThreshold: number;
  labelingThreshold: number;
  lastFrameNumber: number;
  mirrorH: number;
  mirrorV: number;
  rotate: number;
}


// Mapa de tipos de eventos
export type EventType = 
  | "BeaconEvent"
  | "ConnectedEvent"
  | "ComunicationStatusEvent"
  | "IlluminanceReadEvent"
  | "SensorsReadEvent"
  | "PresenceChangeEvent"
  | "ThermalImageCaptureEvent"
;

// Lista de eventos permitidos
export const eventNames: EventType[] = [
  "BeaconEvent",
  "ConnectedEvent",
  "ComunicationStatusEvent",
  "IlluminanceReadEvent",
  "SensorsReadEvent",
  "PresenceChangeEvent",
  "ThermalImageCaptureEvent"
];

// Tipo general para el plugin
export interface SenziioSSEPlugin {
  // Métodos principales
  connect(options: { url: string }): Promise<void>;
  disconnect(): Promise<void>;

  // Sistema de listeners genérico
  addListener<T extends EventType>(
    eventName: T,
    listenerFunc: (event: EventDataMap[T]) => void
  ): Promise<PluginListenerHandle>;

  removeAllListeners(eventName?: EventType): Promise<void>;
}

// Mapeo de tipos de eventos a sus datos
export type EventDataMap = {
  ComunicationStatusEvent: ComunicationStatusEvent;
  IlluminanceReadEvent: IlluminanceReadEvent;
  SensorsReadEvent: SensorsReadEvent;
  PresenceChangeEvent: PresenceChangeEvent;
  ThermalImageCaptureEvent: ThermalImageCaptureEvent;
  BeaconEvent: String;
  ConnectedEvent: String;
};