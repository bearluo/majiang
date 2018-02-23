//
//  LuaEventProxy.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "LuaEventProxy.h"

#import "cocos2d.h"
#import "CCLuaEngine.h"
#import "CCLuaBridge.h"
#import "UMMobClick/MobClick.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceRecord.h"
#import "WXApiHelper.h"
#import "GVoiceHelper.h"
#import "BLWebView.h"
using namespace cocos2d;

extern NSString *const loginFacebook = @"loginFacebook";
extern NSString *const loginYouke = @"loginYouke";
extern NSString *const payCallback = @"payCallback";
extern NSString *const voiceRecord = @"voiceRecord";
extern NSString *const voiceRecordDecibels = @"voiceRecordDecibels";
extern NSString *const wxShare = @"wxShare";
extern NSString *const wxLogin = @"wxLogin";
extern NSString *const wxAutoLogin = @"wxAutoLogin";
extern NSString *const gCloudVoice = @"gCloudVoice";
extern NSString *const webpayCallback = @"webpayCallback";

@implementation LuaEventProxy{
    int callbackHandlerID;
}

    static LuaEventProxy* instance = nil;
    +(id)sharedProxy{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            instance = [[self alloc] init];
            
        });
        
        return instance;
    }

    +(void)setLuaCallBackFunc:(NSDictionary *) params{
        [[LuaEventProxy sharedProxy]setLuaCallBackFunc:params];
    }

-(void)setLuaCallBackFunc:(NSDictionary *) params{
        if (callbackHandlerID != 0){
            LuaBridge::releaseLuaFunctionById(callbackHandlerID); //记得释放
        }
        callbackHandlerID = (int)[[params objectForKey:@"callback"] integerValue];
        
    }

    -(id)init{
        if(self=[super init]) {
        }
        return self;
    }

+(int)getBatterypercentage{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    return deviceLevel*100;
}
+(int)getSignalStrength{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    NSString *wifiNetworkItemView = nil;
    for(id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]){
            dataNetworkItemView = subview;
            break;
        }
//        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]){
//            wifiNetworkItemView = subview;
//            //break;
//        }
    }
    
    int signalStrength = [[dataNetworkItemView valueForKey:@"_signalStrengthBars"] intValue];
    return signalStrength;
}
    // 先要初始化callevent
    -(void)dispatchEvent:(NSString *)event_cmd params:(NSString *)params{
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setValue:event_cmd forKey:@"cmd"];
        [dict setValue:params forKey:@"params"];
        //判断是否能转为Json数据
        BOOL isValidJSONObject =  [NSJSONSerialization isValidJSONObject:dict];
        if (isValidJSONObject) {
            /*
             第一个参数:OC对象 也就是我们dict
             第二个参数:
             NSJSONWritingPrettyPrinted 排版
             kNilOptions 什么也不做
             */
//            Scheduler *scheduler = Director::getInstance()->getScheduler();
//            scheduler->schedule(<#SEL_SCHEDULE selector#>, Director::getInstance()->getRunningScene(), 0, false);
//            scheduler->schedule(
//                [=](float dt){
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    //打印JSON数据
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",ret);
                    LuaBridge::pushLuaFunctionById(callbackHandlerID); //压入需要调用的方法id（假设方法为XG）
                    LuaStack *stack = LuaBridge::getStack();  //获取lua栈
                    stack->pushString([ret cStringUsingEncoding: NSUTF8StringEncoding]);  //将需要通过方法XG传递给lua的参数压入lua栈
                    stack->executeFunction(1);  //根据压入的方法id调用方法XG，并把XG方法参数传递给lua代码
                    //            LuaBridge::releaseLuaFunctionById(callbackHandlerID); //最后记得释放
//            }),Director::getInstance()->getRunningScene(), 0,false);
        }
    }


+ (void)onProfileSignIn:(NSDictionary *) params{
    NSString *puid = [params objectForKey:@"puid"];
    NSString *provider = [params objectForKey:@"provider"];
    if ([puid compare:@""] == 0) {
        return;
    }
    if ([provider compare:@""] == 0) {
        [MobClick profileSignInWithPUID:puid];
    }else{
        [MobClick profileSignInWithPUID:puid provider:provider];
    }
}

+(void)onProfileSignOff{
    [MobClick profileSignOff];
}

+(void)onEvent:(NSDictionary *) params{
    NSString *eventId = [params objectForKey:@"eventId"];
    NSString *jsonStr = [params objectForKey:@"jsonStr"];
    if ([eventId compare:@""] == 0) {
        return;
    }
    
    if ([jsonStr compare:@"null"] == 0) {
        [MobClick event:eventId];
        return;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        [MobClick event:eventId];
        return;
    }
    [MobClick event:eventId attributes:attributes];
}
+(void)onEventValue:(NSDictionary *) params{
    NSString *eventId = [params objectForKey:@"eventId"];
    NSString *jsonStr = [params objectForKey:@"jsonStr"];
    int counter = (int)[[params objectForKey:@"value"] integerValue];
    if ([eventId compare:@""] == 0) {
        return;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        attributes = [[[NSDictionary alloc] init] autorelease];
    }
    [MobClick event:eventId attributes:attributes counter:counter];
}
+(void)reportError:(NSDictionary *) params{
//    NSString *error = [params objectForKey:@"error"];
//    if ([error compare:@""] == 0) {
//        return;
//    }
//    [MobClick repor
}
+(void)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+(void)startRecord:(NSDictionary *) params{
    NSString *path = [params objectForKey:@"path"];
    NSString *what = [params objectForKey:@"what"];
    [[VoiceRecord sharedInstance] startRecord:path what:what ];
}
+(void)stopRecord{
//    NSString *startRecord = [params objectForKey:@"eventId"];
//    NSString *what = [params objectForKey:@"jsonStr"];
    [[VoiceRecord sharedInstance] stopRecord];
}

+(int)copyToClipboard:(NSDictionary *) params{
    NSString *text = [params objectForKey:@"text"];
    UIPasteboard*pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=text;
    return 0;
}

+(int)isWXAppInstalled{
    return [[WXApiHelper sharedHelper] isWXAppInstalled];;
}
+ (int) shareTextToWx:(NSDictionary *) params{
    NSString *transaction = [params objectForKey:@"transaction"];
    NSString *text = [params objectForKey:@"text"];
    NSString *description = [params objectForKey:@"description"];
    int scene = (int)[[params objectForKey:@"scene"] integerValue];
    
    return [[WXApiHelper sharedHelper] sendTextContent:transaction text:text description:description scene:scene];
}
+ (int) shareBitmapToWx:(NSDictionary *) params{
    NSString *transaction = [params objectForKey:@"transaction"];
    NSString *bmpPath = [params objectForKey:@"bmpPath"];
    NSString *description = [params objectForKey:@"description"];
    int scene = (int)[[params objectForKey:@"scene"] integerValue];
    return [[WXApiHelper sharedHelper] sendImageContent:transaction imagePath:bmpPath description:description scene:scene];
}

+ (int) shareWebToWx:(NSDictionary *) params{
    NSString *transaction = [params objectForKey:@"transaction"];
    NSString *bmpPath = [params objectForKey:@"bmpPath"];
    NSString *description = [params objectForKey:@"description"];
    NSString *title = [params objectForKey:@"title"];
    NSString *url = [params objectForKey:@"url"];
    int scene = (int)[[params objectForKey:@"scene"] integerValue];
    return [[WXApiHelper sharedHelper] sendLinkContent:transaction url:url title:title description:description imagePath:bmpPath scene:scene];
}

+(void) loginWx:(NSDictionary *) params;{
    NSString *state = [params objectForKey:@"state"];
    [[WXApiHelper sharedHelper] sendAuthReq:state];
}

+(void) autoLoginWx:(NSDictionary *) params{
    NSString *refresh_token = [params objectForKey:@"refresh_token"];
    NSString *transaction = [params objectForKey:@"transaction"];
    [[WXApiHelper sharedHelper] autoLoginWx:refresh_token transaction:transaction];
}

+(int)loginGCloudVoice:(NSDictionary *) params {
    NSString *openId = [params objectForKey:@"open_id"];
    return [[GVoiceHelper sharedInstance] loginGCloudVoice:openId];
}

+(int)startRecording:(NSDictionary *) params {
    NSString *path = [params objectForKey:@"path"];
    return [[GVoiceHelper sharedInstance] startRecording:path];
}
+(int)stopRecording{
    return [[GVoiceHelper sharedInstance] stopRecording2];
}

+(int)uploadRecordedFile:(NSDictionary *) params {
    NSString *path = [params objectForKey:@"path"];
    return [[GVoiceHelper sharedInstance] uploadRecordedFile:path];
}
+(int)downloadRecordedFile:(NSDictionary *) params {
    NSString *fileID = [params objectForKey:@"file_id"];
    NSString *downloadFilePath = [params objectForKey:@"path"];
    return [[GVoiceHelper sharedInstance] downloadRecordedFile:fileID downloadFilePath:downloadFilePath];
    
}
+(int)playRecordedFile:(NSDictionary *) params {
    NSString *downloadFilePath = [params objectForKey:@"path"];
    return [[GVoiceHelper sharedInstance] playRecordedFile:downloadFilePath];
}
+(int)stopPlayFile{
    return [[GVoiceHelper sharedInstance] stopPlayFile];
}

+(void)displayWebView:(NSDictionary *) params{
    CGFloat x = [[params objectForKey:@"x"] floatValue];
    CGFloat y = [[params objectForKey:@"y"] floatValue];
    CGFloat width = [[params objectForKey:@"width"] floatValue];
    CGFloat height = [[params objectForKey:@"height"] floatValue];
    [[BLWebView sharedInstance] displayWebView:x y:y width:width height:height];
}
+(void)dismissWebView{
    [[BLWebView sharedInstance] dismissWebView];
}
+(void)webViewLoadUrl:(NSDictionary *) params{
    NSString *url = [params objectForKey:@"url"];
    [[BLWebView sharedInstance] webViewLoadUrl:url];
}
+(int)isWebViewVisible{
    return [[BLWebView sharedInstance] isWebViewVisible];
}

-(void)webPayCallBack:(NSString *)mch_id mch_order_id:(NSString *)mch_order_id mch_order_date:(NSString *)mch_order_date{
    if(mch_id==NULL) mch_id = @"";
    if(mch_order_id==NULL) mch_order_id = @"";
    if(mch_order_date==NULL) mch_order_date = @"";
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(1) forKey:@"ret"];
    [dict setValue:mch_id forKey:@"mch_id"];
    [dict setValue:mch_order_id forKey:@"mch_order_id"];
    [dict setValue:mch_order_date forKey:@"mch_order_date"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:webpayCallback params:ret];
}
@end
