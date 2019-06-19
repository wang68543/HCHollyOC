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
    AVAudioRecorder *recoder;
    NSString *recordPath;
}

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
-(void)startRecord{
    NSString *fstr = @"获取录音权限失败";
    AVAudioSession *session = AVAudioSession.sharedInstance;
    
    if (recoder != nil && recoder.isRecording) {
        return;
    }
//    NSError *aserr = nil;
    @try {
        [session setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        NSDictionary *set = @{
                              AVSampleRateKey: @8000,
                              AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatLinearPCM],
                                  AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
                              };
        recordPath = [self getFilePath];
        NSURL *url = [NSURL URLWithString:recordPath];
        recoder = [[AVAudioRecorder alloc] initWithURL:url settings:set error:nil];
        [recoder prepareToRecord];
        [recoder recordForDuration:120];
        [self doStart];
        [self dprint:@"record start"];
        
    } @catch (NSException *exception) {
        NSLog(@"record auth faild");
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        NSString *cpath = recordPath;
        __weak HCHollyRecord *wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself recordTimeLimit: cpath];
        });
    } @finally {
        
    }
//    let fstr = "获取录音权限失败"
//    do{
//        let session = AVAudioSession.sharedInstance()
//        if self.recoder != nil, self.recoder!.isRecording {
//            dprint("正在录音中")
//            return
//        }
//        //            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        try session.setCategory(AVAudioSession.Category.playAndRecord)
//        try session.setActive(true)
//
//        let set = [
//                   AVSampleRateKey: NSNumber(value: 8000),
//                   AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
//                   AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)
//                   ]
//        self.recordPath = self.getFilePath()
//        let url = URL(string: self.recordPath)
//        dprint(recordPath)
//        recoder = try AVAudioRecorder(url: url!, settings: set)
//        recoder?.prepareToRecord()
//        //            recoder?.record()
//        recoder?.record(forDuration: 120)
//        doStart?()
//        dprint("开始录音")
//
//        if timer != nil {
//            self.timer.invalidate()
//            self.timer = nil
//        }
//        //            self.timer = Timer(fireAt: Date(timeIntervalSinceNow: 10), interval: 5, target: self, selector: #selector(recordTimeLimit), userInfo: nil, repeats: false)
//
//        let cpath = recordPath
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 60) {
//            self.recordTimeLimit(onlyUrl: cpath)
//        }
//    }
//    catch{
//        dprint("录音初始化失败")
//        self.doFailed?(fstr)
//    }
}
-(void)stop{
    
    if (recoder == nil) {
        [self dprint:@"record not start"];
        return;
    }
    if (recoder.isRecording) {
        [recoder stop];
        [AVAudioSession.sharedInstance setActive:NO error:nil];
        recoder = nil;
        [self doStop];
        [self uploadRecord:recordPath];
        [self dprint:@"record stop"];
    }
    
}
-(void)cancel{
    if (recoder == nil) {
        [self dprint:@"record not start"];
        return;
    }
    if (recoder.isRecording) {
        [recoder stop];
        [AVAudioSession.sharedInstance setActive:NO error:nil];
        recoder = nil;
        [self doCancel];
        [self dprint:@"record cancel"];
    }
}
-(void)uploadRecord:(NSString*)filePath{
    
//    NSString *fName = filePath.lastPathComponent;
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *fileData = [NSData dataWithContentsOfURL:url];
    if (fileData != nil) {
        __weak HCHollyRecord *wself = self;
        [[HCAliyunOss share] uploadC5FileData:fileData done:^(BOOL iss, NSString * _Nonnull resu) {
            [wself dprint:resu];
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.doUpload(iss, resu);
            });
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
    [self dprint: temp];
    return temp;
}


-(void)dprint:(NSString*) log{
    if (showlog) {
        NSLog(@"%@",log);
    }
}


@end
