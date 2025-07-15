package com.senziio.capacitorsse;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSources;

public class SenziioSSE {

    public final Map<String, EventSource> connections = new HashMap<>();

    public SenziioSSE(Context context) {
        //
    }

    public void connect(String url, SenziioSSEPluginCallback callback) {
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

        EventSource eventSource = EventSources.createFactory(client).newEventSource(request, callback);

        connections.put(callback.getId(), eventSource);
    }

    public void disconnect(String connectionId) {
        if (connectionId == null || !connections.containsKey(connectionId)) {
            String msg = String.format("ID de conexión erróneo: %s", (connectionId == null ? "(null)" : connectionId));
            throw new RuntimeException(msg);
        }

        EventSource connection = connections.remove(connectionId);
        if (connection != null) {
            try {
                // Método más limpio para desconectar
                connection.cancel();

                // Pequeño delay para permitir procesamiento interno
                // pero sin bloquear el hilo principal
                new Handler(Looper.getMainLooper()).postDelayed(() -> {
                    // Limpieza adicional si es necesaria
                }, 50);
            } catch (Exception e) {
                // Ignorar excepciones durante cancelación
            }
        }
    }

}