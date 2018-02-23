//
//  StorekitHelper.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "YoukeHelper.h"
#import "LuaEventProxy.h"
#import "Function.h"
extern NSString *const loginYouke;
@implementation YoukeHelper{
}

    static YoukeHelper* instance = nil;
    
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
    -(void)loginYouke{
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setValue:@(1) forKey:@"ret"];
        dict = [Function getLoginCommentData:dict];
        NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [[LuaEventProxy sharedProxy]dispatchEvent:loginYouke params:ret];
    }
    +(void)loginYouke{
        [[YoukeHelper sharedHelper] loginYouke];
    }
@end
