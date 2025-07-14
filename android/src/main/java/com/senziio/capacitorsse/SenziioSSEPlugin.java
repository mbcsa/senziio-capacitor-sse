package com.senziio.capacitorsse;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "SenziioSSE")
public class SenziioSSEPlugin extends Plugin {

    private SenziioSSE sse;

    @Override
    public void load() {
        super.load();
        this.sse = new SenziioSSE(getContext());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void connect(PluginCall call) {
        try {
            String url = call.getString("url");

            if (url == null) {
                throw new IllegalArgumentException("URL es requerida");
            }

            call.setKeepAlive(true);
            sse.connect(url, new SenziioSSEPluginCallback(call, bridge));
        } catch (Exception e) {
            call.reject(e.getMessage(), e);
        }
    }

    @PluginMethod
    public void disconnect(PluginCall call) {
        try {
            String connectionId = call.getString("connectionId");

            if (connectionId == null) {
                throw new IllegalArgumentException("connectionId es requerido");
            }

            sse.disconnect(connectionId);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage(), e);
        }
    }
}