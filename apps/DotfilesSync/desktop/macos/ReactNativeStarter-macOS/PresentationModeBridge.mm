#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PresentationModeModule, NSObject)
RCT_EXTERN_METHOD(getMode:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setMode:(NSString *)mode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
