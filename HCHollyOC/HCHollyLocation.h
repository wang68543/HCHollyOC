//
//  HCHollyLocation.h
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCHollyLocation : NSObject

+(HCHollyLocation*)share;

-(void)getLocationBack:(void(^)(CLLocation*))locationDone failed:(void(^)(NSError*))locationFail;
@end

NS_ASSUME_NONNULL_END
