//
//  HCHollyWebView.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyWebView.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HCHollyRecord.h"

@implementation HCHollyWebView

static NSString *c6Url = @"";

+(void)showlog:(BOOL)iss{
    [HCHollyRecord showlog:iss];
}
+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb{
//    NSLog(@"%@", account);
    NSString *urlPath = @"http://a1.7x24cc.com/commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=\(account)&chatId=\(chatId)";

    NSString *pars = @"";
    for (NSString *key in param) {
        pars = [NSString stringWithFormat:@"%@%@=%@&",pars,key,param[key]];
    }
    
    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"初始化失败，请检查网络，或重新初始化 %@",error);
            cb(false, @"");
            return;
        }
        else{
            NSString *dStr = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];

            NSDictionary *dc = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error:nil];
            if (dc != nil) {
                NSInteger succ = dc[@"success"];
                if (succ == 1) {
                    NSString *url = dc[@"interface"];
                    if ([url containsString:@"?"]) {
                        c6Url = [NSString stringWithFormat:@"%@&%@",url,pars];
                    }
                    else{
                        c6Url = [NSString stringWithFormat:@"%@?%@",url,pars];
                    }
                }
                cb(true, @"初始化holly成功");
                NSLog(@"%@",dc);
            }
            NSLog(@"%@",dStr);
        }
    }];
    [task resume];
    
}

@end
