//
//  Function.h
//  poker
//
//  Created by 罗昊 on 2017/6/9.
//
//

#ifndef GVoiceHelper_h
#define GVoiceHelper_h
#import <AVFoundation/AVFoundation.h>
#import "GVoice.h"
@interface GVoiceHelperController : UIViewController <GVGCloudVoiceDelegate>
@end
@interface GVoiceHelper : NSObject
+(id)sharedInstance;
-(void)pause;
-(void)resume;
-(int)loginGCloudVoice:(NSString *)openId;
-(int)startRecording:(NSString *)path;
-(int)stopRecording2;
-(int)uploadRecordedFile:(NSString *)path;
-(int)downloadRecordedFile:(NSString *)fileID  downloadFilePath:(NSString *)downloadFilePath;
-(int)playRecordedFile:(NSString *)downloadFilePath;
-(int)stopPlayFile;
@end

#endif /* Function_h */
