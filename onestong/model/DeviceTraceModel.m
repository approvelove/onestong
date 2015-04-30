//
//  DeviceTraceModel.m
//  onestong
//
//  Created by 李健 on 14-6-14.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DeviceTraceModel.h"

@implementation DeviceTraceModel
@synthesize  latitude,longtitude,userId,createTime,date,location;


+ (DeviceTraceModel *)fromDictionary:(NSDictionary *)obj
{
     DeviceTraceModel *deviceModel = [[DeviceTraceModel alloc] init];
    if (obj) {
        deviceModel.location = obj[@"lc"];
        deviceModel.longtitude = [obj[@"lo"] doubleValue];
        deviceModel.latitude = [obj[@"la"] doubleValue];
        deviceModel.userId = obj[@"ud"];
        deviceModel.createTime = [obj[@"ct"] longLongValue];
        deviceModel.date = obj[@"da"];
    }
    return deviceModel;
}
@end
