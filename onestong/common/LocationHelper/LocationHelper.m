//
//  LocationHelper.m
//  MyTest
//
//  Created by 李健 on 14-3-4.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "LocationHelper.h"
#import "CLLocation+Sino.h"

static NSInteger const HORIZONTALACCURACYNUM = 2000;
static NSInteger const VERTICALACCURACYNUM = 2000;

@interface LocationHelper ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
    NSMutableDictionary *locationDict;
}
@end


@implementation LocationHelper
- (void)initGPSLocation
{
    if (![CLLocationManager locationServicesEnabled]) { //判断是否有定位服务
        return;
    }
    if (locationManager == Nil) {
        locationDict = [NSMutableDictionary dictionary];
        locationManager = [[CLLocationManager alloc] init]; //初始化定位框架
        if (CURRENT_VERSION >= 8.0) {
            [locationManager requestWhenInUseAuthorization];
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//系统设置最好的一个，最耗电的。
        locationManager.distanceFilter = 100;//移动100米通知位置改变.
        locationManager.activityType = CLActivityTypeFitness;
    }
}

- (void)startLocation
{
    if (locationManager&&self) {
        locationManager.delegate = self;
        [self performSelector:@selector(upLoadingLocation) withObject:self afterDelay:0.5];
    }
}

- (void)upLoadingLocation
{
    [locationManager startUpdatingLocation]; //启动定位服务.
}

- (void)stopLocation
{
    if (locationManager&&self) {
        [self performSelector:@selector(cancelLocationUpdate) withObject:self afterDelay:0.5];
    }
}


- (void)cancelLocationUpdate
{
    [locationManager stopUpdatingLocation]; //停止定位服务.
}
#pragma mark -CLLocation delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"DD");
    if (self) {
        [self stopLocation];
        [self printLocationErrorInfomation:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"更新定位数据中");
    CLLocation *lastLocation = [locations lastObject];
    //获取算法转换后的坐标
    CLLocation *newLocation = [self getCorrectLocationWithWGS84:lastLocation];
    
    NSTimeInterval eventInterval = [lastLocation.timestamp timeIntervalSinceNow];
    
    if (abs(eventInterval)<60.0) { //过滤掉60秒以上的事件
        if (lastLocation.horizontalAccuracy>=0 && lastLocation.horizontalAccuracy<HORIZONTALACCURACYNUM &&lastLocation.verticalAccuracy<VERTICALACCURACYNUM) {  //过滤掉大于100米经纬度范围外的数据
            locationDict[@"latitude"] = @(newLocation.coordinate.latitude);
            locationDict[@"longitude"] = @(newLocation.coordinate.longitude);
            [self geoCodeReverseWithLocation:newLocation];
        }
        else
        {
//            HORIZONTALACCURACYNUM = 2000; //当失败时扩大精度限制
//            VERTICALACCURACYNUM = 2000;//当失败时扩大精度
            NSLog(@"精度超过2000的定位");
            [self printLocationErrorInfomation:nil];
        }
    }
    else
    {
        NSLog(@"大于30秒以上的定位");
        [self printLocationErrorInfomation:nil];
    }
    [self stopLocation];
}

- (CLLocation *)getCorrectLocationWithWGS84:(CLLocation *)wgsloc
{
    CLLocation *adjustLoc = nil;
    adjustLoc = [wgsloc locationMarsFromEarth];
    return adjustLoc;
}
//地理信息反编码
- (void)geoCodeReverseWithLocation:(CLLocation *)location
{
    NSLog(@"enter now");
    if (geoCoder == Nil) {
        geoCoder = [[CLGeocoder alloc] init];
    }
    if ([geoCoder isGeocoding]) {
        [geoCoder cancelGeocode];
    }
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count]>0) {
            CLPlacemark *foundPlaceMark = [placemarks lastObject];
            locationDict[@"address"] = foundPlaceMark.name;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION object:nil userInfo:locationDict];
        }
        else
        {
            NSLog(@"无法解码的定位");
            locationDict[@"address"] = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION object:nil userInfo:locationDict];
        }
    }];
}

- (void)printLocationErrorInfomation:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_ERROR object:nil];
}

- (void)showAlertWithTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert show];
}
@end
