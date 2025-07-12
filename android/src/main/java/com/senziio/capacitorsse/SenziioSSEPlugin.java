package com.senziio.capacitorsse;

import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.util.concurrent.TimeUnit;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;
import okhttp3.sse.EventSources;

@CapacitorPlugin(name = "SenziioSSE")
public class SenziioSSEPlugin extends Plugin {
    // private OkHttpClient client = new OkHttpClient();
    private EventSource eventSource;

    @PluginMethod
    public void connect(PluginCall call) {
        String url = call.getString("url");
        if (url == null) {
            call.reject("URL es requerida");
            return;
        }

        // 1. Crear un cliente OkHttp con timeouts personalizados
        OkHttpClient client = new OkHttpClient.Builder()
                .readTimeout(0, TimeUnit.MILLISECONDS) // Timeout de lectura infinito para SSE
                .connectTimeout(30, TimeUnit.SECONDS) // Timeout de conexión razonable
                .writeTimeout(30, TimeUnit.SECONDS)   // Timeout de escritura razonable
                .build();

        Request request = new Request.Builder()
                .url(url)
                .header("Accept", "text/event-stream") // Es buena práctica añadir este header
                .build();

        EventSourceListener listener = new EventSourceListener() {
            @Override
            public void onOpen(EventSource eventSource, Response response) {
                JSObject ret = new JSObject();
                ret.put("status", "connected");
                notifyListeners("connected", ret);
            }

            @Override
            public void onEvent(EventSource eventSource, String id, String type, String data) {
                JSObject ret = new JSObject();
                ret.put("type", type != null ? type : "message"); // Asegurar que el tipo no sea nulo
                ret.put("data", data);
                notifyListeners(type != null ? type : "message", ret);
            }

            @Override
            public void onFailure(EventSource eventSource, Throwable t, Response response) {
                // Notificar error de conexión
                JSObject errorObj = new JSObject();
                errorObj.put("message", "Connection failed");
                if (t != null) {
                    errorObj.put("error", t.getMessage());
                }
                notifyListeners("connection_error", errorObj);

                // Notificar desconexión
                JSObject disconObj = new JSObject();
                disconObj.put("status", "disconnected");
                disconObj.put("reason", "error");
                notifyListeners("disconnected", disconObj);

                call.reject(t != null ? t.getMessage() : "Unknown error");
                
                if (eventSource != null) {
                    eventSource.cancel();
                }
            }

            @Override
            public void onClosed(EventSource eventSource) {
                // Notificar desconexión limpia
                JSObject disconObj = new JSObject();
                disconObj.put("status", "disconnected");
                disconObj.put("reason", "closed");
                notifyListeners("disconnected", disconObj);
            }
        };

        eventSource = EventSources.createFactory(client)
                .newEventSource(request, listener);

        call.resolve();
    }

    @PluginMethod
    public void disconnect(PluginCall call) {
        if (eventSource != null) {
            eventSource.cancel();
            
            // Notificar desconexión manual
            JSObject disconObj = new JSObject();
            disconObj.put("status", "disconnected");
            disconObj.put("reason", "manual");
            notifyListeners("disconnected", disconObj);
        }
        call.resolve();
    }
}