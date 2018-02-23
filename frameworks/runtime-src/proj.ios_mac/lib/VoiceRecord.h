//
//  Function.h
//  poker
//
//  Created by 罗昊 on 2017/6/9.
//
//

#ifndef VoiceRecord_h
#define VoiceRecord_h
#import <AVFoundation/AVFoundation.h>
@interface VoiceRecord : NSObject
+(id)sharedInstance;
-(void)startRecord:(NSString *)path what:(NSString *)what;
-(void)stopRecord;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@end

#endif /* Function_h */
