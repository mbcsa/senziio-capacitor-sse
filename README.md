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


#### ComunicationStatusEvent

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


#### String

Allows manipulation and formatting of text strings and determination and location of substrings within strings.

| Prop         | Type                | Description                                                  |
| ------------ | ------------------- | ------------------------------------------------------------ |
| **`length`** | <code>number</code> | Returns the length of a <a href="#string">String</a> object. |

| Method                | Signature                                                                                                                      | Description                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**          | () =&gt; string                                                                                                                | Returns a string representation of a string.                                                                                                  |
| **charAt**            | (pos: number) =&gt; string                                                                                                     | Returns the character at the specified index.                                                                                                 |
| **charCodeAt**        | (index: number) =&gt; number                                                                                                   | Returns the Unicode value of the character at the specified location.                                                                         |
| **concat**            | (...strings: string[]) =&gt; string                                                                                            | Returns a string that contains the concatenation of two or more strings.                                                                      |
| **indexOf**           | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the position of the first occurrence of a substring.                                                                                  |
| **lastIndexOf**       | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the last occurrence of a substring in the string.                                                                                     |
| **localeCompare**     | (that: string) =&gt; number                                                                                                    | Determines whether two strings are equivalent in the current locale.                                                                          |
| **match**             | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; <a href="#regexpmatcharray">RegExpMatchArray</a> \| null                | Matches a string with a regular expression, and returns an array containing the results of that search.                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replaceValue: string) =&gt; string                                       | Replaces text in a string, using a regular expression or search string.                                                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replacer: (substring: string, ...args: any[]) =&gt; string) =&gt; string | Replaces text in a string, using a regular expression or search string.                                                                       |
| **search**            | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; number                                                                  | Finds the first substring match in a regular expression search.                                                                               |
| **slice**             | (start?: number \| undefined, end?: number \| undefined) =&gt; string                                                          | Returns a section of a string.                                                                                                                |
| **split**             | (separator: string \| <a href="#regexp">RegExp</a>, limit?: number \| undefined) =&gt; string[]                                | Split a string into substrings using the specified separator and return them as an array.                                                     |
| **substring**         | (start: number, end?: number \| undefined) =&gt; string                                                                        | Returns the substring at the specified location within a <a href="#string">String</a> object.                                                 |
| **toLowerCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to lowercase.                                                                              |
| **toLocaleLowerCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Converts all alphabetic characters to lowercase, taking into account the host environment's current locale.                                   |
| **toUpperCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to uppercase.                                                                              |
| **toLocaleUpperCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Returns a string where all alphabetic characters have been converted to uppercase, taking into account the host environment's current locale. |
| **trim**              | () =&gt; string                                                                                                                | Removes the leading and trailing white space and line terminator characters from a string.                                                    |
| **substr**            | (from: number, length?: number \| undefined) =&gt; string                                                                      | Gets a substring beginning at the specified location and having the specified length.                                                         |
| **valueOf**           | () =&gt; string                                                                                                                | Returns the primitive value of the specified object.                                                                                          |


#### RegExpMatchArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |


#### RegExp

| Prop             | Type                 | Description                                                                                                                                                          |
| ---------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`source`**     | <code>string</code>  | Returns a copy of the text of the regular expression pattern. Read-only. The regExp argument is a Regular expression object. It can be a variable name or a literal. |
| **`global`**     | <code>boolean</code> | Returns a Boolean value indicating the state of the global flag (g) used with a regular expression. Default is false. Read-only.                                     |
| **`ignoreCase`** | <code>boolean</code> | Returns a Boolean value indicating the state of the ignoreCase flag (i) used with a regular expression. Default is false. Read-only.                                 |
| **`multiline`**  | <code>boolean</code> | Returns a Boolean value indicating the state of the multiline flag (m) used with a regular expression. Default is false. Read-only.                                  |
| **`lastIndex`**  | <code>number</code>  |                                                                                                                                                                      |

| Method      | Signature                                                                     | Description                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **exec**    | (string: string) =&gt; <a href="#regexpexecarray">RegExpExecArray</a> \| null | Executes a search on a string using a regular expression pattern, and returns an array containing the results of that search. |
| **test**    | (string: string) =&gt; boolean                                                | Returns a Boolean value that indicates whether or not a pattern exists in a searched string.                                  |
| **compile** | () =&gt; this                                                                 |                                                                                                                               |


#### RegExpExecArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |


### Type Aliases


#### EventType

<code>"BeaconEvent" | "ConnectedEvent" | "<a href="#comunicationstatusevent">ComunicationStatusEvent</a>" | "<a href="#illuminancereadevent">IlluminanceReadEvent</a>" | "<a href="#sensorsreadevent">SensorsReadEvent</a>" | "<a href="#presencechangeevent">PresenceChangeEvent</a>" | "<a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>"</code>


#### EventDataMap

<code>{ <a href="#comunicationstatusevent">ComunicationStatusEvent</a>: <a href="#comunicationstatusevent">ComunicationStatusEvent</a>; <a href="#illuminancereadevent">IlluminanceReadEvent</a>: <a href="#illuminancereadevent">IlluminanceReadEvent</a>; <a href="#sensorsreadevent">SensorsReadEvent</a>: <a href="#sensorsreadevent">SensorsReadEvent</a>; <a href="#presencechangeevent">PresenceChangeEvent</a>: <a href="#presencechangeevent">PresenceChangeEvent</a>; <a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>: <a href="#thermalimagecaptureevent">ThermalImageCaptureEvent</a>; BeaconEvent: <a href="#string">String</a>; ConnectedEvent: <a href="#string">String</a>; }</code>

</docgen-api>
