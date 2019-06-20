//
//  HCAliyunOss.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCAliyunOss.h"


@interface HCAliyunOss(){

    
}
@property(nonatomic, strong)NSString *uploadAudioUrl;

@end

@implementation HCAliyunOss

static HCAliyunOss *_instance = nil;
+(HCAliyunOss*)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HCAliyunOss alloc]init];
        _instance.uploadAudioUrl = @"http://im.7x24cc.com/open_platform/uploadVoiceFile";
    });
    return _instance;
}
-(void)uploadC5FileData:(NSData*)fileData done:(void(^)(BOOL iss, NSString* resu))done{
    NSData *body = fileData;
    NSURL *url = [NSURL URLWithString:_uploadAudioUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.HTTPBody = body;
//    NSLog(@"%@",req);
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"NSURLSessionDataTask %@",error);
            done(false, @"holly录音上传失败");
            return;
        }
        else{
            NSString *dStr = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
            done(true, dStr);
//            NSDictionary *dc = NSJSONSerialization JSONObjectWithData:<#(nonnull NSData *)#> options:<#(NSJSONReadingOptions)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>
        }
    }];
    [task resume];
    
}
//func uploadC5File(fileData: Data, done: @escaping ((_ iss: Bool, _ resu: String)->Void)){
//    let body = fileData
//    let url = URL(string: uploadAudioUrl)!
//    var req = URLRequest(url: url)
//    req.httpMethod = "POST"
//    req.httpBody = body
//    let task = URLSession.shared.dataTask(with: req) { (obj, resp, err) in
//        if err != nil || obj == nil{
//            print(err)
//            done(false, "")
//            return
//        }
//        //            print(err)
//        //            print(obj)
//        //            print(resp)
//        let dStr = String(data: obj!, encoding: String.Encoding.utf8)
//        //            print(dStr)
//        //            if let dc = try? JSONSerialization.jsonObject(with: obj!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]{
//        done(true, dStr!)
//        //            }
//        //            else{
//        //                done(false, ["VoiceTimelength":"0","VoiceUrl":"结果转化异常"])
//        //            }
//
//    }
//    task.resume()
//}

@end
