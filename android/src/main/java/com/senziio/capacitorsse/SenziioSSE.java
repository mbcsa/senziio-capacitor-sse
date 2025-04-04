package com.senziio.capacitorsse;

import android.content.Context;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;
import okhttp3.sse.EventSources;

public class SenziioSSE {
    private EventSource eventSource;
    private final OkHttpClient client;
    private final String url;
    private final EventListener listener;

    public interface EventListener {
        void onEvent(String type, String data);
        void onError(String error);
    }

    public SenziioSSE(Context context, String url, EventListener listener) {
        this.client = new OkHttpClient();
        this.url = url;
        this.listener = listener;
    }

    public void connect() {
        Request request = new Request.Builder()
                .url(url)
                .build();

        EventSourceListener esListener = new EventSourceListener() {
            @Override
            public void onEvent(EventSource eventSource, String id, String type, String data) {
                listener.onEvent(type, data);
            }

            @Override
            public void onFailure(EventSource eventSource, Throwable t, Response response) {
                listener.onError(t != null ? t.getMessage() : "Error desconocido");
            }
        };

        eventSource = EventSources.createFactory(client).newEventSource(request, esListener);
    }

    public void disconnect() {
        if (eventSource != null) {
            eventSource.cancel();
        }
    }
}