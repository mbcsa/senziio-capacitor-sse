#import <Capacitor/Capacitor.h>

CAP_PLUGIN(SenziioSSE, "SenziioSSE",
    CAP_PLUGIN_METHOD(connect, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(disconnect, CAPPluginReturnPromise);
)