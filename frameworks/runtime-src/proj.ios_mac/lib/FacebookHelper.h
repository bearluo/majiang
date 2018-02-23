//
//  FacebookHelper.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef FacebookHelper_h
#define FacebookHelper_h

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookHelper:NSObject
    
    
+(void) loginFacebook;
+(id)sharedHelper;
    
    
-(void) loginFacebook;
@end
#endif /* FacebookHelper_h */
