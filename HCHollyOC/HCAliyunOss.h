//
//  HCAliyunOss.h
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCAliyunOss : NSObject
+(HCAliyunOss*)share;
-(void)uploadC5FileData:(NSData*)fileData done:(void(^)(BOOL iss, NSString* resu))done;
@end

NS_ASSUME_NONNULL_END
