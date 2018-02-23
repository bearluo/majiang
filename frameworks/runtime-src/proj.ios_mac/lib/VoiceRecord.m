//
//  Function.m
//  poker
//
//  Created by 罗昊 on 2017/6/9.
//
//

#import <Foundation/Foundation.h>
#import "LuaEventProxy.h"
#import "VoiceRecord.h"

extern NSString *voiceRecord;
extern NSString *voiceRecordDecibels;
@implementation VoiceRecord{
    NSTimer *levelTimer;
}
static VoiceRecord* instance = nil;
+(id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

- (void)startRecord:(NSString *)path what:(NSString *)what{
    NSLog(@"开始录音");
    [self stopRecord];
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
        [self fail: [NSString stringWithFormat:@"Error creating session: %@",[sessionError description]] what:what];
    }else{
        [session setActive:YES error:nil];
    }
    
    self.session = session;
    
    //2.获取文件路径
    NSURL *recordFileUrl = [NSURL fileURLWithPath:path];
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    _recorder = [[AVAudioRecorder alloc] initWithURL:recordFileUrl settings:recordSetting error:nil];
    if (_recorder) {
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
        [self fail:@"音频格式和文件存储格式不匹配,无法初始化Recorder" what:what];
    }
}

-(void)stopRecord{
    NSLog(@"停止录音");
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    if(levelTimer) {
        [levelTimer invalidate];
        levelTimer = nil;
    }
}

/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [_recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [_recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(level) forKey:@"level"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:voiceRecordDecibels params:ret];
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_textLabel setText:[NSString stringWithFormat:@"%f", level*120]];
//    });
}

-(void)fail:(NSString *)error what:(NSString *)what{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(3) forKey:@"ret"];
    [dict setValue:what forKey:@"what"];
    [dict setValue:error forKey:@"error"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:voiceRecord params:ret];
}


@end
