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
* [`addListener('sseEvent', ...)`](#addlistenersseevent-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)

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


### addListener('sseEvent', ...)

```typescript
addListener(eventName: 'sseEvent', listenerFunc: (event: SSEEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                              |
| ------------------ | ----------------------------------------------------------------- |
| **`eventName`**    | <code>'sseEvent'</code>                                           |
| **`listenerFunc`** | <code>(event: <a href="#sseevent">SSEEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### SSEEvent

| Prop       | Type                |
| ---------- | ------------------- |
| **`type`** | <code>string</code> |
| **`data`** | <code>string</code> |

</docgen-api>
