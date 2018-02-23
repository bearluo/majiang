//
//  BLWebView.h
//  cangzhoumajiang
//
//  Created by 罗昊 on 2017/9/13.
//
//

#ifndef BLWebView_h
#define BLWebView_h
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
@interface BLWebView : NSObject<UIWebViewDelegate, NJKWebViewProgressDelegate>
+(id)sharedInstance;
-(void)initWebView:(UIView *)parent;
-(void)displayWebView:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;
-(void)dismissWebView;
-(void)webViewLoadUrl:(NSString *)path;
-(int)isWebViewVisible;
@end


#endif /* BLWebView_h */
