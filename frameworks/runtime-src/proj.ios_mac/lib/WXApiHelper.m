//
//  FacebookHelper.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "WXApiHelper.h"
#import "LuaEventProxy.h"
#import "Function.h"

extern NSString *wxLogin;
extern NSString *wxAutoLogin;
extern NSString *wxShare;
@implementation WXApiHelper{
}
const static int MAX_SIZE_THUMBNAIL_BATE = 32768;
const static int MAX_SIZE_LARGE_BATE = 10485760;
const static NSString *APP_ID = @"wx73964edf31faa87b";
const static NSString *APP_SECRET = @"a5b964b35ccb2ea9d9b32e1dc80e4980";
const static NSString *access_token_url = @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=APP_ID&secret=APP_SECRET&code=CODE&grant_type=authorization_code";
const static NSString *refresh_token_url=@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APP_ID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN";

typedef void(^callback)(NSString *json);
static WXApiHelper* instance = nil;
    
+(id)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}
    
-(id)init{
    if(self=[super init]) {
    }
    return self;
}

-(void)registerApp {
    [WXApi registerApp:APP_ID];
}

-(void)WXHttpGet:(NSString *)urlStr callback:(callback)callback {
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //url不允许为中文等特殊字符，需要进行字符串的转码为URL字符串，例如空格转换后为“%20”；
//    NSURL *url=[NSURL URLWithString:urlStr];
//    //2.根据ＷＥＢ路径创建一个请求
//    NSURLRequest  *request=[NSURLRequest requestWithURL:url];
//    NSURLResponse *respone;//获取连接的响应信息，可以为nil
//    NSError *error;        //获取连接的错误时的信息，可以为nil
////    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        //3.得到服务器数据
//        NSData  *data = [NSURLConnection sendSynchronousRequest:request returningResponse:respone error:&error];
//        if(data==nil)
//        {
//            NSLog(@"WXHttpGet:%@,请重试",error);
////            dispatch_async(dispatch_get_main_queue(),^{
//                callback(NULL);
////            });
//        }else {
////            dispatch_async(dispatch_get_main_queue(),^{
//                NSString *ret = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                callback(ret);
////            });
//        }
////    });
    // 1.创建一个网络路径
    NSURL *url=[NSURL URLWithString:urlStr];
    // 2.创建一个网络请求
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    // 3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 4.根据会话对象，创建一个Task任务：
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"从服务器获取到数据");
        /*
         对从服务器获取到的数据data进行相应的处理：
         */
        if(data==nil)
        {
            NSLog(@"WXHttpGet:%@,请重试",error);
//            dispatch_async(dispatch_get_main_queue(),^{
            callback(NULL);
//            });
        }else {
//            dispatch_async(dispatch_get_main_queue(),^{
            NSString *ret = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(ret);
//            });
        }
    }];
    // 5.最后一步，执行任务（resume也是继续执行）:
    [sessionDataTask resume];
}

-(void) onReq:(BaseReq*)req {
    //    onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
}

-(void) onResp:(BaseResp*)resp {
    //    如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        [self onShare:resp];
    }else if ([resp isKindOfClass:[SendAuthResp class]]) {
        [self onLogin:resp];
    }

}

-(void) onShare:(BaseResp*)resp {
    switch (resp.errCode) {
        case 0: {
            NSLog(@"success");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:_transaction forKey:@"transaction"];
            [dict setValue:@(1) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxShare params:ret];
            break;
        }
        case -2: {
            NSLog(@"Cancelled");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:_transaction forKey:@"transaction"];
            [dict setValue:@(2) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxShare params:ret];
            break;
        }
        default: {
            NSLog(@"Process error");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:_transaction forKey:@"transaction"];
            [dict setValue:@(3) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxShare params:ret];
            break;
        }
    }
}

-(void) onLogin:(BaseResp*)resp {
    SendAuthResp *temp = (SendAuthResp *)resp;
    const NSString *state = temp.state;
    switch (resp.errCode) {
        case 0: {
            const NSString *code = temp.code;
            NSLog(@"success %@",code);
            NSString *url = [[[access_token_url stringByReplacingOccurrencesOfString:@"APP_ID" withString:APP_ID] stringByReplacingOccurrencesOfString:@"APP_SECRET" withString:APP_SECRET] stringByReplacingOccurrencesOfString:@"CODE" withString:code];
            [self WXHttpGet:url callback:^(NSString *json){
                if(json==NULL) {
                    NSLog(@"get Process error");
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:@(3) forKey:@"ret"];
                    [dict setValue:@(-4) forKey:@"code"];
                    [dict setValue:@"json is null" forKey:@"error"];
                    [dict setValue:state forKey:@"state"];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:wxLogin params:ret];
                }else{
                    NSLog(@"success");
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:json forKey:@"data"];
                    [dict setValue:state forKey:@"state"];
                    [dict setValue:@(1) forKey:@"ret"];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:wxLogin params:ret];
                }
            }];
            break;
        }
        case -2: {
            NSLog(@"Cancelled");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(2) forKey:@"ret"];
            [dict setValue:state forKey:@"state"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxLogin params:ret];
            break;
        }
        default: {
            NSLog(@"Process error");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(3) forKey:@"ret"];
            [dict setValue:resp.errCode forKey:@"code"];
            [dict setValue:resp.errStr forKey:@"error"];
            [dict setValue:state forKey:@"state"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxLogin params:ret];
            break;
        }
    }
}

- (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    data = UIImageJPEGRepresentation(resultImage, 1.0);
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1.0);
    }
    
    return resultImage;
}

-(BOOL) isWXAppInstalled {
    BOOL ret = [WXApi isWXAppInstalled];
    return ret;
}

-(BOOL) sendTextContent:(NSString *)transaction text:(NSString *)text description:(NSString *)description scene:(int)scene
{
    _transaction = transaction;
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.text = text;
    req.bText = YES;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

- (BOOL) sendImageContent:(NSString *)transaction imagePath:(NSString *)imagePath description:(NSString *)description scene:(int)scene
{
    _transaction = transaction;
    WXMediaMessage *message = [WXMediaMessage message];
    message.thumbData = UIImageJPEGRepresentation([self compressImage:[UIImage imageNamed:imagePath] toByte:MAX_SIZE_THUMBNAIL_BATE],1.0);
//    [message setThumbImage: img];
    
    WXImageObject *ext = [WXImageObject object];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res5thumb" ofType:@"png"];
    NSLog(@"filepath :%@",imagePath);
//    ext.imageData = [NSData dataWithContentsOfFile:filePath];
    
    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
//    UIImage* image = [UIImage imageWithData:ext.imageData];
    ext.imageData = UIImageJPEGRepresentation([self compressImage:[UIImage imageNamed:imagePath] toByte:MAX_SIZE_LARGE_BATE],1.0);
    
    //    UIImage* image = [UIImage imageNamed:@"res5thumb.png"];
    //    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

- (BOOL) sendLinkContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene
{
    _transaction = transaction;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = UIImageJPEGRepresentation([self compressImage:[UIImage imageNamed:imagePath] toByte:MAX_SIZE_THUMBNAIL_BATE],1.0);
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

-(BOOL) sendMusicContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene
{
    _transaction = transaction;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = UIImageJPEGRepresentation([self compressImage:[UIImage imageNamed:imagePath] toByte:MAX_SIZE_THUMBNAIL_BATE],1.0);
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = url;
//    ext.musicDataUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}
-(BOOL) sendVideoContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene
{
    _transaction = transaction;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = UIImageJPEGRepresentation([self compressImage:[UIImage imageNamed:imagePath] toByte:MAX_SIZE_THUMBNAIL_BATE],1.0);
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

-(BOOL) sendAuthReq :(NSString *)state{
    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
    req.scope = @"snsapi_userinfo";
    req.state = state;
    return [WXApi sendReq:req];
}

-(NSString *) getTransaction{
    return _transaction;
}

-(void) autoLoginWx:(NSString *)refresh_token transaction:(NSString *)transaction {
    _transaction = transaction;
    NSString *url = [[[refresh_token_url stringByReplacingOccurrencesOfString:@"APP_ID" withString:APP_ID] stringByReplacingOccurrencesOfString:@"APP_SECRET" withString:APP_SECRET] stringByReplacingOccurrencesOfString:@"REFRESH_TOKEN" withString:refresh_token];
    [self WXHttpGet:url callback:^(NSString *json){
        if(json==NULL) {
            NSLog(@"get Process error");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(3) forKey:@"ret"];
            [dict setValue:@(-4) forKey:@"code"];
            [dict setValue:@"json is null" forKey:@"error"];
            [dict setValue:@"ios" forKey:@"transaction"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxAutoLogin params:ret];
        }else{
            NSLog(@"success");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:json forKey:@"data"];
            [dict setValue:@"ios" forKey:@"transaction"];
            [dict setValue:@(1) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:wxAutoLogin params:ret];
        }
    }];
}

@end
