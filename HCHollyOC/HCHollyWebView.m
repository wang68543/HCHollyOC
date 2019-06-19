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

@implementation HCHollyWebView

+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb{
    NSLog(@"%@", account);
}

@end
