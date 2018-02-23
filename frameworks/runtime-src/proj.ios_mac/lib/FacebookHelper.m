//
//  FacebookHelper.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "FacebookHelper.h"
#import "LuaEventProxy.h"
#import "Function.h"
extern NSString *loginFacebook;
@implementation FacebookHelper{
    FBSDKLoginManager *loginManager;
    UIViewController *viewCtr;
}

static FacebookHelper* instance = nil;
    
+(id)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

+(void)loginFacebook{
    [[FacebookHelper sharedHelper] loginFacebook];
}
    
    
-(id)init{
    if(self=[super init]) {
        loginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

-(void)loginFacebook{
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"logOut");
        [loginManager logOut];
    }
    
    [loginManager logInWithReadPermissions:@[@"public_profile"] fromViewController:viewCtr handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Process error");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(3) forKey:@"ret"];
            [dict setValue:[error localizedDescription] forKey:@"error"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(2) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
        } else {
            NSLog(@"Logged in");
            NSString *tokenString = [[result token] tokenString];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,gender"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    NSLog(@"fetched user:%@ cmd:%@",result,loginFacebook);
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:[result objectForKey:@"name"] forKey:@"name"];
                    [dict setValue:[result objectForKey:@"id"] forKey:@"id"];
                    [dict setValue:[result objectForKey:@"gender"] forKey:@"gender"];
                    [dict setValue:tokenString forKey:@"fb_token"];
                    [dict setValue:@(1) forKey:@"ret"];
                    dict = [Function getLoginCommentData:dict];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
                }else{
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:@(3) forKey:@"ret"];
                    [dict setValue:[error localizedDescription] forKey:@"error"];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
                }
            }];
        }
    }];
}
    
@end
