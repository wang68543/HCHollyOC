//
//  HCHollyLocation.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyLocation.h"

@interface HCHollyLocation()<CLLocationManagerDelegate>

@property(nonatomic, strong)CLLocationManager *manager;

@property(nonatomic, assign) void(^locationDone)(CLLocation*);
@property(nonatomic, assign) void(^locationFail)(NSError*);

@end

@implementation HCHollyLocation

static HCHollyLocation *_instance = nil;
+(HCHollyLocation*)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HCHollyLocation alloc]init];


    });
    return _instance;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
//        [manager startUpdatingLocation];
    }
    else{
        NSLog(@"没有定位权限");
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _locationDone(locations.firstObject);
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    _locationFail(error);
}

-(void)getLocationBack:(void(^)(CLLocation*))locationDone failed:(void(^)(NSError*))locationFail{
    [self reqAuth];
    self.locationDone = locationDone;
    self.locationFail = locationFail;
}

-(void)reqAuth{
    [_manager requestWhenInUseAuthorization];
}

@end
