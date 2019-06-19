//
//  HCHollyRecord.h
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCHollyRecord : NSObject

+(HCHollyRecord*)manager;
+(void)showlog:(BOOL)iss;
@end

NS_ASSUME_NONNULL_END
