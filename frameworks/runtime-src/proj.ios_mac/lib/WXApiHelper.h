//
//  FacebookHelper.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef WXApiHelper_h
#define WXApiHelper_h

#import "WXApi.h"
#import "WXApiObject.h"
@interface WXApiHelper:NSObject<WXApiDelegate>
@property (copy, nonatomic)   NSString *transaction;
+(id)sharedHelper;

-(void)registerApp;
-(void) onReq:(BaseReq*)req;
-(void) onResp:(BaseResp*)resp;
-(BOOL) isWXAppInstalled;
-(BOOL) sendTextContent:(NSString *)transaction text:(NSString *)text description:(NSString *)description scene:(int)scene;
- (BOOL) sendImageContent:(NSString *)transaction imagePath:(NSString *)imagePath description:(NSString *)description scene:(int)scene;
- (BOOL) sendLinkContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene;
-(BOOL) sendMusicContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene;
-(BOOL) sendVideoContent:(NSString *)transaction url:(NSString *)url title:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath scene:(int)scene;
-(BOOL) sendAuthReq :(NSString *)state;
-(void) autoLoginWx:(NSString *)refresh_token transaction:(NSString *)transaction;
@end
#endif /* FacebookHelper_h */
