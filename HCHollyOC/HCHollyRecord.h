//
//  HCHollyRecord.h
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HCHollyRecordDelegate <NSObject>

-(void)onUpload:(BOOL)iss mess:(NSString*)mess;

@end

@interface HCHollyRecord : NSObject

+(HCHollyRecord*)manager;
+(void)showlog:(BOOL)iss;

@property(nonatomic, weak) id<HCHollyRecordDelegate> delegate;

-(void)onStart:(void(^)(void))b;
-(void)onStop:(void(^)(void))b;
-(void)onCancel:(void(^)(void))b;
-(void)onUpload:(void(^)(BOOL iss, NSString *mess))b;
-(void)onFailed:(void(^)(NSString *mess))b;

-(void)stop;
-(void)start;
-(void)cancel;

@end

NS_ASSUME_NONNULL_END
