package com.senziio.capacitorsse;

import androidx.annotation.NonNull;

import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;

import java.net.SocketException;

import okhttp3.Response;
import okhttp3.internal.http2.StreamResetException;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;

public class SenziioSSEPluginCallback extends EventSourceListener {

    private final PluginCall call;

    private final Bridge bridge;

    public SenziioSSEPluginCallback(PluginCall call, Bridge bridge) {
        this.call = call;
        this.bridge = bridge;
    }

    public String getId() {
        return call.getCallbackId();
    }

    @Override
    public void onOpen(@NonNull EventSource eventSource, @NonNull Response response) {
        bridge.executeOnMainThread(() -> {
            call.resolve(status("connected"));
        });
    }

    @Override
    public void onEvent(@NonNull EventSource eventSource, String id, String type, @NonNull String data) {
        bridge.executeOnMainThread(() -> {
            call.resolve(message(type, data));
        });
    }

    @Override
    public void onFailure(@NonNull EventSource eventSource, Throwable t, Response response) {
        // Ignorar errores esperados durante desconexión
        if (isExpectedDisconnectError(t)) {
            bridge.executeOnMainThread(() -> {
                call.resolve(status("disconnected"));
                call.release(bridge);
            });
            return;
        }

        // Manejar otros errores normalmente
        bridge.executeOnMainThread(() -> {
            if (t instanceof Exception ex) {
                call.reject(ex.getMessage(), ex);
            } else {
                call.reject("Unknown error", error(t));
            }
        });
    }

    private boolean isExpectedDisconnectError(Throwable t) {
        // Error de stream cancelado
        if (t instanceof StreamResetException) {
            StreamResetException sre = (StreamResetException) t;
            return "CANCEL".equals(sre.errorCode.toString());
        }

        // Error de socket cerrado
        if (t instanceof SocketException) {
            return "Socket closed".equals(t.getMessage());
        }

        return false;
    }

    @Override
    public void onClosed(@NonNull EventSource eventSource) {
        bridge.executeOnMainThread(() -> {
            call.resolve(status("disconnected"));
            call.release(bridge);
        });
    }

    @NonNull
    private static JSObject status(String s) {
        JSObject obj = new JSObject();
        obj.put("type", "status");
        obj.put("status", s);
        return obj;
    }

    @NonNull
    private static JSObject message(String type, String data) {
        JSObject obj = new JSObject();
        obj.put("type", "message");

        JSObject payload = new JSObject();
        payload.put("type", type != null ? type : "message"); // Asegurar que el tipo no sea nulo
        payload.put("data", data);
        obj.put("payload", payload);

        return obj;
    }

    @NonNull
    private static JSObject error(Throwable t) {
        JSObject obj = new JSObject();
        obj.put("message", t.getMessage());
        return obj;
    }
}
