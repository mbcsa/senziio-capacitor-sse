package com.senziio.capacitorsse;

import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

// Imports necesarios
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;
import okhttp3.sse.EventSources;

@CapacitorPlugin(name = "SenziioSSE")
public class SenziioSSEPlugin extends Plugin {
    private OkHttpClient client = new OkHttpClient();
    private EventSource eventSource;

    @PluginMethod
    public void connect(PluginCall call) {
        String url = call.getString("url");
        if (url == null) {
            call.reject("URL es requerida");
            return;
        }

        Request request = new Request.Builder()
                .url(url)
                .build();

        EventSourceListener listener = new EventSourceListener() {
            @Override
            public void onEvent(EventSource eventSource, String id, String type, String data) {
                JSObject ret = new JSObject();
                ret.put("type", type);
                ret.put("data", data);
                notifyListeners("sseEvent", ret);
            }

            @Override
            public void onFailure(EventSource eventSource, Throwable t, Response response) {
                Log.e("SSE_DEBUG", "Error en SSE", t);
                String errorMsg = "Error: ";
                errorMsg += t != null ? t.getMessage() : 
                        response != null ? "HTTP " + response.code() : "Desconocido";
                
                call.reject(errorMsg);
                
                if (eventSource != null) {
                    eventSource.cancel(); // Cerrar conexión
                }
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
        }
        call.resolve();
    }
}