//
//  HCHollyWebView.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyWebView.h"
#import <UIKit/UIKit.h>
#import "HCHollyRecord.h"
#import "HCHollyLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface HCHollyWebView()<WKScriptMessageHandler, HCHollyRecordDelegate>

@property(nonatomic, strong) WKWebView *webview;
@property(nonatomic, strong) UIProgressView *progress;


@end

@implementation HCHollyWebView

static NSString *c6Url = @"";

+(void)showlog:(BOOL)iss{
    [HCHollyRecord showlog:iss];
}
+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb{
//    NSLog(@"%@", account);
//    NSString *urlPath = [NSString stringWithFormat: @"http://123.56.20.159:3000/commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=%@&chatId=%@",account, chatId];
    NSString *urlPath = [NSString stringWithFormat: @"http://a1.7x24cc.com/commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=%@&chatId=%@",account, chatId];

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
                NSInteger succ = [dc[@"success"] integerValue];
                
                if (succ == 1) {
                    NSString *url = dc[@"interface"];
                    if ([url containsString:@"?"]) {
                        c6Url = [NSString stringWithFormat:@"%@&%@",url,pars];
                    }
                    else{
                        c6Url = [NSString stringWithFormat:@"%@?%@",url,pars];
                    }
                    NSLog(@"%@",c6Url);
                    cb(true, @"初始化holly成功");
                    return;
                }
//                NSLog(@"%@",dc);
            }
//            NSLog(@"%@",dStr);
            cb(false, @"");
        }
    }];
    [task resume];
    
}

- (void)dealloc
{
    NSLog(@"holly webview dealloc");
}

-(WKWebView*)getC6WebViewWithFrame:(CGRect)frame{
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    self.webview = [[WKWebView alloc] initWithFrame:frame configuration:conf];
//    _webview.UIDelegate = self;
    _webview.navigationDelegate = self;
    
    [self addHandler];
    [self loadUrl: c6Url];
    
    return _webview;
    
}

-(void)addHandler{
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordStart"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordStop"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordCancel"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"getLocation"];
}

-(void)removeHandler{
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordStart"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordStop"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordCancel"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"getLocation"];
}

-(void)loadUrl:(NSString*)sss{
    NSURL *url = [NSURL URLWithString:sss];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:req];
    [self initRecord];
    
    
}

-(void)initRecord{
    __weak HCHollyWebView *wself = self;
    [HCHollyRecord.manager onStart:^{
        NSString *jstr = @"hollyRecordStart()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onCancel:^{
        NSString *jstr = @"hollyRecordCancel()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    
    [HCHollyRecord.manager onFailed:^(NSString * _Nonnull mess) {
        NSString *jstr = @"hollyRecordFailed()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onStop:^{
        NSString *jstr = @"hollyRecordStop()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onUpload:^(BOOL iss, NSString *downUrl){
        NSString *jstr = [NSString stringWithFormat:@"hollyRecordUpload('%@')", downUrl];
        if (!iss) {
            jstr = @"hollyRecordFailed()";
        }
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    HCHollyRecord.manager.delegate = self;
    
}
-(void)onUpload:(BOOL)iss mess:(NSString *)mess{
    NSString *jstr = [NSString stringWithFormat:@"hollyRecordUpload('%@')", mess];
    if (!iss) {
        jstr = @"hollyRecordFailed()";
    }
    [self.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"recordStart"]) {
        [HCHollyRecord.manager start];
    }
    else if ([message.name isEqualToString:@"recordStop"]){
        [HCHollyRecord.manager stop];
    }
    else if ([message.name isEqualToString:@"recordCancel"]){
        [HCHollyRecord.manager cancel];
    }
    else if ([message.name isEqualToString:@"getLocation"]){
        __weak HCHollyWebView *wself = self;
        [HCHollyLocation.share getLocationBack:^(CLLocation * _Nonnull loc) {
            if (loc == nil) {
                return;
            }
            NSString *js = [NSString stringWithFormat:@"hollyGetLocation('%f','%f')", loc.coordinate.latitude, loc.coordinate.longitude];
            [wself.webview evaluateJavaScript:js completionHandler:nil];
        } failed:^(NSError * _Nonnull err) {
            NSString *js = [NSString stringWithFormat:@"hollyGetLocationFailed('%@')", err.localizedDescription];
            [wself.webview evaluateJavaScript:js completionHandler:nil];
        }];
    }
//    NSLog(@"%@",message.name);
    
//case "getLocation":
//    weak var wself = self
//
//    let loc = HCHollyLocation.share
//    loc.getLocation(back: { (loc) in
//        if loc == nil {return}
//        let jstr = "hollyGetLocation('\(loc!.coordinate.latitude)','\(loc!.coordinate.longitude)')"
//        wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//            //                    print(obj)
//            //                    print(err)
//        })
//    }, failed: { err in
//        let jstr = "hollyGetLocationFailed('\(err.localizedDescription)')"
//        wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//            //                    print(obj)
//            //                    print(err)
//        })
//    })
//default:
//    print("没有匹配到")
//}
}

@end

@implementation HCHollyWebView (WKNavigationDelegate)

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation -> %@",error);
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation -> %@",error);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation -> %@", webView);
}

@end
