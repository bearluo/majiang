//
//  LuaEventProxy.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef LuaEventProxy_h
#define LuaEventProxy_h

@interface LuaEventProxy:NSObject{
}
    +(id)sharedProxy;
    +(void)setLuaCallBackFunc:(NSDictionary *) params;
+(int)getBatterypercentage;
+(int)getSignalStrength;
+ (void)onProfileSignIn:(NSDictionary *) params;
+(void)onProfileSignOff;
+(void)onEvent:(NSDictionary *) params;
+(void)onEventValue:(NSDictionary *) params;
+(void)reportError:(NSDictionary *) params;
+(void)vibrate;
+(int)copyToClipboard:(NSDictionary *) params;
+(int)isWXAppInstalled;
+(int)shareTextToWx:(NSDictionary *) params;
+(int)shareBitmapToWx:(NSDictionary *) params;
+(void)loginWx:(NSDictionary *) params;
+(void)autoLoginWx:(NSDictionary *) params;
+(int)loginGCloudVoice:(NSDictionary *) params;
+(int)startRecording:(NSDictionary *) params;
+(int)stopRecording;
+(int)uploadRecordedFile:(NSDictionary *) params;
+(int)downloadRecordedFile:(NSDictionary *) params;
+(int)playRecordedFile:(NSDictionary *) params;
+(int)stopPlayFile;
+(void)displayWebView:(NSDictionary *) params;
+(void)dismissWebView;
+(void)webViewLoadUrl:(NSDictionary *) params;
+(int)isWebViewVisible;
-(void)webPayCallBack:(NSString *)mch_id mch_order_id:(NSString *)mch_order_id mch_order_date:(NSString *)mch_order_date;
-(void)dispatchEvent:(NSString *)event_cmd params:(NSString *)params;
    // Constants

@end
#endif /* FacebookHelper_h */
