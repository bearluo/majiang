//
//  Function.m
//  poker
//
//  Created by 罗昊 on 2017/6/9.
//
//

#import <Foundation/Foundation.h>
#import "GVoiceHelper.h"
#import "LuaEventProxy.h"

extern NSString *gCloudVoice;
@implementation GVoiceHelperController{}
- (void) onJoinRoom:(enum GCloudVoiceCompleteCode) code withRoomName: (const char * _Nullable)roomName andMemberID:(int) memberID {
}

- (void) onStatusUpdate:(enum GCloudVoiceCompleteCode) status withRoomName: (const char * _Nullable)roomName andMemberID:(int) memberID {
    
}

- (void) onQuitRoom:(enum GCloudVoiceCompleteCode) code withRoomName: (const char * _Nullable)roomName {
}

- (void) onMemberVoice:    (const unsigned int * _Nullable)members withCount: (int) count {
}

- (void) onUploadFile: (enum GCloudVoiceCompleteCode) code withFilePath: (const char * _Nullable)filePath andFileID:(const char * _Nullable)fileID  {
    NSLog(@"onUploadFile");
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@"OnUploadFile" forKey:@"method"];
    [dict setValue:@(1) forKey:@"ret"];
    [dict setValue:@(code) forKey:@"code"];
    [dict setValue:[NSString stringWithCString:filePath  encoding:NSUTF8StringEncoding] forKey:@"filePath"];
    [dict setValue:[NSString stringWithCString:fileID  encoding:NSUTF8StringEncoding] forKey:@"fileID"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:gCloudVoice params:ret];

}

- (void) onDownloadFile: (enum GCloudVoiceCompleteCode) code  withFilePath: (const char * _Nullable)filePath andFileID:(const char * _Nullable)fileID {
    NSLog(@"onDownloadFile");
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@"OnDownloadFile" forKey:@"method"];
    [dict setValue:@(1) forKey:@"ret"];
    [dict setValue:@(code) forKey:@"code"];
    [dict setValue:[NSString stringWithCString:filePath  encoding:NSUTF8StringEncoding] forKey:@"filePath"];
    [dict setValue:[NSString stringWithCString:fileID  encoding:NSUTF8StringEncoding] forKey:@"fileID"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:gCloudVoice params:ret];
}

- (void) onPlayRecordedFile:(enum GCloudVoiceCompleteCode) code withFilePath: (const char * _Nullable)filePath {
    NSLog(@"onPlayRecordedFile");
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@"OnPlayRecordedFile" forKey:@"method"];
    [dict setValue:@(1) forKey:@"ret"];
    [dict setValue:@(code) forKey:@"code"];
    [dict setValue:[NSString stringWithCString:filePath  encoding:NSUTF8StringEncoding] forKey:@"filePath"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:gCloudVoice params:ret];
}

- (void) onApplyMessageKey:(enum GCloudVoiceCompleteCode) code {
    NSLog(@"onApplyMessageKey");
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@"OnApplyMessageKey" forKey:@"method"];
    [dict setValue:@(1) forKey:@"ret"];
    [dict setValue:@(code) forKey:@"code"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:gCloudVoice params:ret];
}

- (void) onSpeechToText:(enum GCloudVoiceCompleteCode) code withFileID:(const char * _Nullable)fileID andResult:( const char * _Nullable)result {
    
}

- (void) onRecording:(const unsigned char* _Nullable) pAudioData withLength: (unsigned int) nDataLength {
    
}

- (void) onStreamSpeechToText:(enum GCloudVoiceCompleteCode) code withError:(int) error andResult:(const char *_Nullable)result{
    
}
@end
@implementation GVoiceHelper{
    NSTimer *_pollTimer;
    GVoiceHelperController * controller;
}
static GVoiceHelper* instance = nil;
+(id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

-(id)init{
    if(self=[super init]) {
        controller = [[GVoiceHelperController alloc] init];
    }
    return self;
}

-(void)pause{
    [[GVGCloudVoice sharedInstance] pause];
}

-(void)resume{
    [[GVGCloudVoice sharedInstance] resume];
}

-(int)loginGCloudVoice:(NSString *)openId {
    int ret = [[GVGCloudVoice sharedInstance] setAppInfo:[@"1216780538" UTF8String] withKey:[@"d175a49c831bac3a8b11489d4268d7de" UTF8String] andOpenID:[openId UTF8String]];
    NSLog(@"loginGCloudVoice ret:%x",ret);
    if ( ret != 0 ) return ret;
    [[GVGCloudVoice sharedInstance] initEngine];
    [[GVGCloudVoice sharedInstance] setDelegate:controller];
    [[GVGCloudVoice sharedInstance] setMode:Messages];
    if (_pollTimer==NULL) {
        _pollTimer = [NSTimer scheduledTimerWithTimeInterval:1.000/15 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [[GVGCloudVoice sharedInstance] poll];
        }];
    }
    return [[GVGCloudVoice sharedInstance] applyMessageKey:10000];
}

-(int)startRecording:(NSString *)path {
    return [[GVGCloudVoice sharedInstance] startRecording:[path UTF8String]];
}
-(int)stopRecording2{
    return [[GVGCloudVoice sharedInstance] stopRecording];
}

-(int)uploadRecordedFile:(NSString *)path {
    return [[GVGCloudVoice sharedInstance] uploadRecordedFile:[path UTF8String] timeout:10000];
}
-(int)downloadRecordedFile:(NSString *)fileID  downloadFilePath:(NSString *)downloadFilePath {
    return [[GVGCloudVoice sharedInstance] downloadRecordedFile:[fileID UTF8String] filePath:[downloadFilePath UTF8String] timeout:10000];
    
}
-(int)playRecordedFile:(NSString *)downloadFilePath {
    return [[GVGCloudVoice sharedInstance] playRecordedFile:[downloadFilePath UTF8String]];
}
-(int)stopPlayFile{
    return [[GVGCloudVoice sharedInstance] stopPlayFile];
}


@end
