#import <Capacitor/Capacitor.h>

CAP_PLUGIN(SenziioSSE, "SenziioSSE",
    CAP_PLUGIN_METHOD(connect, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(disconnect, CAPPluginReturnNone);
)