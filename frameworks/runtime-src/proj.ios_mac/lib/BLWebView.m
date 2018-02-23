//
//  BLWebView.m
//  cangzhoumajiang
//
//  Created by 罗昊 on 2017/9/13.
//
//

#import <Foundation/Foundation.h>
#import "BLWebView.h"
#import "LuaEventProxy.h"
@implementation BLWebView{
    UIWebView * webView;
    NJKWebViewProgress * webViewProgress;
    NJKWebViewProgressView * webViewProgressView;
}
static BLWebView* instance = nil;
+(id)sharedInstance{
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
+ (CGFloat) getRetinaDisplayScale
{
    CGFloat scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    NSLog(@"isRetinaDisplay：scale:%f",scale);
    return scale;
}
-(void)initWebView:(UIView *)parent{
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [parent addSubview: webView];
    [webView setHidden:YES];
    webViewProgress = [[NJKWebViewProgress alloc] init];
    webView.delegate = webViewProgress;
    webViewProgress.webViewProxyDelegate = self;
    webViewProgress.progressDelegate = self;
    
    CGRect barFrame = CGRectMake(0,
                                 0,
                                 300,
                                 2);
    webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    webViewProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [webViewProgressView setProgress:0 animated:NO];
    [webView addSubview:webViewProgressView];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [webViewProgressView setProgress:progress animated:NO];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
}
// 如果返回NO，代表不允许加载这个请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // 说明协议头是ios
    if ([@"tianyoumajiang" isEqualToString:request.URL.scheme]) {
        if ([@"webpaycallback" isEqualToString:request.URL.host]){
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [[request.URL query] componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts lastObject] forKey:[elts firstObject]];
            }
            [[LuaEventProxy sharedProxy] webPayCallBack:[params objectForKey:@"mch_id"] mch_order_id:[params objectForKey:@"mch_order_id"] mch_order_date:[params objectForKey:@"mch_order_date"]];
        }
        return NO;
    }
    
    return YES;
}

-(void)displayWebView:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    NSLog(@"displayWebView：x:%f y:%f width:%f height:%f",x,y,width,height);
    if (webView) {
        CGFloat scale = [BLWebView getRetinaDisplayScale];
        [webView setFrame:CGRectMake(x/scale, y/scale, width/scale, height/scale)];
        NSLog(@"displayWebView isRetinaDisplay：x:%f y:%f width:%f height:%f",x/scale,y/scale,width/scale,height/scale);

        [webView setHidden:NO];
    }
}
-(void)dismissWebView{
    if (webView) {
        [webView setHidden:YES];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
        [webView loadRequest:request];
    }
}
-(void)webViewLoadUrl:(NSString *)url{
    if (webView) {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:request];
    }
}
-(int)isWebViewVisible{
    if (webView) {
        if ([webView isHidden]){
            return 0;
        }else{
            return 1;
        }
    }
    return 0;
}
@end

