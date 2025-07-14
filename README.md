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
* [`disconnect(...)`](#disconnect)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### connect(...)

```typescript
connect(options: { url: string; }, callback: ConnectionEventCallback) => Promise<ConnectionID>
```

| Param          | Type                                                                        |
| -------------- | --------------------------------------------------------------------------- |
| **`options`**  | <code>{ url: string; }</code>                                               |
| **`callback`** | <code><a href="#connectioneventcallback">ConnectionEventCallback</a></code> |

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### disconnect(...)

```typescript
disconnect(options: { connectionId: ConnectionID; }) => Promise<void>
```

| Param         | Type                                   |
| ------------- | -------------------------------------- |
| **`options`** | <code>{ connectionId: string; }</code> |

--------------------


### Type Aliases


#### ConnectionEventCallback

<code>((event?: <a href="#connectionevent">ConnectionEvent</a>, err?: any) =&gt; Promise&lt;void&gt;|void)</code>


#### ConnectionEvent

<code><a href="#messageconnectionevent">MessageConnectionEvent</a> | <a href="#statusconnectionevent">StatusConnectionEvent</a></code>


#### MessageConnectionEvent

<code>{ type: 'message', payload: <a href="#messagepayload">MessagePayload</a> }</code>


#### MessagePayload

<code>{ type: string, data: string }</code>


#### StatusConnectionEvent

<code>{ type: 'status', status: 'connected'|'disconnected' }</code>


#### ConnectionID

<code>string</code>

</docgen-api>
