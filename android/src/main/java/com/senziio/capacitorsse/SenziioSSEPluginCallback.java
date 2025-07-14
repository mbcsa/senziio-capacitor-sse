package com.senziio.capacitorsse;

import android.util.Log;

import androidx.annotation.NonNull;

import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;

import java.io.IOException;
import java.net.SocketException;

import okhttp3.Response;
import okhttp3.internal.http2.ErrorCode;
import okhttp3.internal.http2.StreamResetException;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;

public class SenziioSSEPluginCallback extends EventSourceListener {
    private static final String TAG = "SenziioSSEPluginCallback";

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
        call.resolve(status("connected"));
    }

    @Override
    public void onEvent(@NonNull EventSource eventSource, String id, String type, @NonNull String data) {
        call.resolve(message(type, data));
    }

    @Override
    public void onFailure(@NonNull EventSource eventSource, Throwable t, Response response) {
        if (t == null || t instanceof SocketException || (t instanceof StreamResetException ex && ex.errorCode == ErrorCode.CANCEL)) {
            call.resolve(status("disconnected"));
            return;
        }

        call.reject(t.getMessage(), t instanceof Exception ex ? ex : null);
    }

    @Override
    public void onClosed(@NonNull EventSource eventSource) {
        call.resolve(status("disconnected"));
        call.release(bridge);
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
