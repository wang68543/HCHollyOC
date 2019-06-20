//
//  HCHollyRecord.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyRecord.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HCAliyunOss.h"

@interface HCHollyRecord(){
    NSTimer *timer;
    
    NSString *recordPath;
}

@property(nonatomic, strong) AVAudioRecorder *recoder;
@property(nonatomic, assign) void(^doStart)(void);
@property(nonatomic, assign) void(^doStop)(void);
@property(nonatomic, assign) void(^doCancel)(void);
@property(nonatomic, assign) void(^doUpload)(BOOL iss, NSString *mess);
@property(nonatomic, assign) void(^doFailed)(NSString *mess);

@end


@implementation HCHollyRecord

static BOOL showlog = true;
static id _instance = nil;

+(HCHollyRecord*)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

+(void)showlog:(BOOL)iss{
    showlog = iss;
}

- (void)dealloc
{
    [self dprint:@"holly record dealloc"];
}

-(void)onStart:(void(^)(void))b{
    self.doStart = b;
}
-(void)onStop:(void(^)(void))b{
    self.doStop = b;
}
-(void)onCancel:(void(^)(void))b{
    self.doCancel = b;
}
-(void)onUpload:(void(^)(BOOL iss, NSString *mess))b{
//    NSLog(@"on upload fffff");
    self.doUpload = b;
}
-(void)onFailed:(void(^)(NSString *mess))b{
    self.doFailed = b;
}

-(void)start{
    
    NSString *fstr = @"获取录音权限失败";
    AVAudioSession *session = [AVAudioSession sharedInstance];
    __block BOOL hasRecordAuth = true;
    __weak HCHollyRecord *wself = self;
    [session requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted){
                hasRecordAuth = granted;
                wself.doFailed(fstr);
            }
            else{
                [wself startRecord];
            }
        });
    }];
    
}
- (NSMutableDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}
-(void)startRecord{
    NSString *fstr = @"获取录音权限失败";
    AVAudioSession *session = AVAudioSession.sharedInstance;
    if(![session setCategory: AVAudioSessionCategoryPlayAndRecord error:nil]){
        NSLog(@"111");
    }
    if(![session setActive:YES error:nil]){
        NSLog(@"222");
    }
    
    if (_recoder != nil && _recoder.isRecording) {
        return;
    }
//    NSError *aserr = nil;
    @try {
        NSError *err;
        NSDictionary *set = @{
//                              AVSampleRateKey: @(8000),
//                              AVFormatIDKey: @(kAudioFormatLinearPCM),
//                                  AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
                              AVSampleRateKey: [NSNumber numberWithFloat: 44100.0],
                              AVLinearPCMBitDepthKey:[NSNumber numberWithInt:16],
                            AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatLinearPCM],
                            
                              };
        NSDictionary *settings =@{
                                  // 音频格式
                                  AVFormatIDKey:@(kAudioFormatLinearPCM),
                                  // 采样率
                                  AVSampleRateKey:@8000.0f,
                                  // 通道数
                                  AVNumberOfChannelsKey:@1,
                                  // 位深
                                  AVEncoderBitDepthHintKey:@16,
                                  // 音频质量
                                  AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
                                  };
        recordPath = [self getFilePath];
        NSURL *url = [NSURL URLWithString:recordPath];
        self.recoder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error: &err];
        
        
        if (err) {
            NSLog(@"创建录音失败%@",err.localizedDescription);
        }
        
        [_recoder prepareToRecord];
//        [recoder recordForDuration:120];
        [_recoder record];
        
        [self doStart];
        [self dprint:@"record start"];
        
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        NSString *cpath = recordPath;
        __weak HCHollyRecord *wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself recordTimeLimit: cpath];
        });
    } @catch (NSException *exception) {
        NSLog(@"record auth faild");
        self.doFailed(@"record 初始化 faild");
    } @finally {
        
    }
}
-(void)stop{
//    NSLog(@"-->stop");
    if (_recoder == nil) {
        [self dprint:@"record not start"];
        return;
    }
    if (_recoder.isRecording) {
        [_recoder stop];
        [AVAudioSession.sharedInstance setActive:NO error:nil];
        _recoder = nil;
        [self doStop];
        [self uploadRecord:recordPath];
        [self dprint:@"record stop"];
    }
    
}
-(void)cancel{
//    NSLog(@"-->cancel");
    if (_recoder == nil) {
        [self dprint:@"record not start"];
        return;
    }
    if (_recoder.isRecording) {
        [_recoder stop];
        [AVAudioSession.sharedInstance setActive:NO error:nil];
        _recoder = nil;
        [self doCancel];
        [self dprint:@"record cancel"];
    }
}
-(void)uploadRecord:(NSString*)filePath{
//    NSLog(@"-->uploadRecord");
    
//    NSString *fName = filePath.lastPathComponent;
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *fileData = [NSData dataWithContentsOfURL:url];
//    NSLog(@"%@",fileData);
    if (fileData != nil) {
        __weak HCHollyRecord *wself = self;
        [[HCAliyunOss share] uploadC5FileData:fileData done:^(BOOL iss, NSString * _Nonnull resu) {
            [wself dprint:resu];
            if (!iss) {
                [wself dprint:resu];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.doUpload(iss, resu);
                    [wself.delegate onUpload:iss mess:resu];
                });
            }
        }];
    }
}
-(void)recordTimeLimit:(NSString*)onlyUrl{
    if ([onlyUrl isEqualToString:recordPath]) {
        return;
    }
    if (timer != nil && timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
    NSLog(@"录音::时间限制::");
    [self stop];
}
-(NSString*)getFilePath{
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *cachePath = NSTemporaryDirectory();
    
    NSString *temp = [NSString stringWithFormat:@"%@%@.wav",cachePath, uuid];
//    NSString *temp = [NSString stringWithFormat:@"%@%@.caf",cachePath, uuid];
    [self dprint: temp];
    return temp;
}


-(void)dprint:(NSString*) log{
    if (showlog) {
        NSLog(@"%@",log);
    }
}


@end
