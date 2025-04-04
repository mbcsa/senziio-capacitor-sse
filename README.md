# senziio-capacitor-sse

SSE Events for Android

## Install

```bash
npm install senziio-capacitor-sse
npx cap sync
```

## API

<docgen-index>

* [`connect(...)`](#connect)
* [`disconnect()`](#disconnect)
* [`addListener(T, ...)`](#addlistenert-)
* [`removeAllListeners(...)`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### connect(...)

```typescript
connect(options: { url: string; }) => Promise<void>
```

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ url: string; }</code> |

--------------------


### disconnect()

```typescript
disconnect() => Promise<void>
```

--------------------


### addListener(T, ...)

```typescript
addListener<T extends EventType>(eventName: T, listenerFunc: (event: EventDataMap[T]) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                             |
| ------------------ | ------------------------------------------------ |
| **`eventName`**    | <code>T</code>                                   |
| **`listenerFunc`** | <code>(event: EventDataMap[T]) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners(...)

```typescript
removeAllListeners(eventName?: EventType | undefined) => Promise<void>
```

| Param           | Type                                            |
| --------------- | ----------------------------------------------- |
| **`eventName`** | <code><a href="#eventtype">EventType</a></code> |

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### CommunicationStatusEvent

| Prop          | Type                                                                                                               |
| ------------- | ------------------------------------------------------------------------------------------------------------------ |
| **`mqtt`**    | <code>{ enable: boolean; host: string; normal_mqtt_port: string; state: string; }</code>                           |
| **`network`** | <code>{ ethIP: string; signal: string; ssid: string; state: string; wifiIPAddr: string; wifiMode: string; }</code> |


#### IlluminanceReadEvent

| Prop              | Type                |
| ----------------- | ------------------- |
| **`light_level`** | <code>string</code> |


#### SensorsReadEvent

| Prop             | Type                                                                 |
| ---------------- | -------------------------------------------------------------------- |
| **`airQuality`** | <code>{ co2: string; humidity: string; temperature: string; }</code> |


#### PresenceChangeEvent

| Prop               | Type                |
| ------------------ | ------------------- |
| **`b`**            | <code>string</code> |
| **`c`**            | <code>string</code> |
| **`count_person`** | <code>string</code> |
| **`p`**            | <code>string</code> |
| **`r`**            | <code>number</code> |
| **`x`**            | <code>string</code> |
| **`y`**            | <code>string</code> |


#### ThermalImageCaptureEvent

| Prop                    | Type                    |
| ----------------------- | ----------------------- |
| **`detectedPixels`**    | <code>number</code>     |
| **`diffFrame15`**       | <code>number[][]</code> |
| **`diffThreshold`**     | <code>number</code>     |
| **`labelingThreshold`** | <code>number</code>     |
| **`lastFrameNumber`**   | <code>number</code>     |
| **`mirrorH`**           | <code>number</code>     |
| **`mirrorV`**           | <code>number</code>     |
| **`rotate`**            | <code>number</code>     |


### Type Aliases


#### EventType

<code>"<a href="#communicationstatusevent">CommunicationStatusEvent</a>" | "<a href="#illuminancereadevent">IlluminanceReadEvent</a>" | "<a href="#sensorsreadevent">SensorsReadEvent</a>" | "<a href="#presencechangeevent">PresenceChangeEvent</a>" | "<a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>"</code>


#### EventDataMap

<code>{ <a href="#communicationstatusevent">CommunicationStatusEvent</a>: <a href="#communicationstatusevent">CommunicationStatusEvent</a>; <a href="#illuminancereadevent">IlluminanceReadEvent</a>: <a href="#illuminancereadevent">IlluminanceReadEvent</a>; <a href="#sensorsreadevent">SensorsReadEvent</a>: <a href="#sensorsreadevent">SensorsReadEvent</a>; <a href="#presencechangeevent">PresenceChangeEvent</a>: <a href="#presencechangeevent">PresenceChangeEvent</a>; <a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>: <a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>; }</code>

</docgen-api>
