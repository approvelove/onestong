//
//  DeviceTraceService.h
//  onestong
//
//  Created by 李健 on 14-6-14.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

//////获取设备轨迹接口

#import "BaseService.h"

static NSString *const FIND_DEVICE_IN_DATE_NOTIFICATION = @"find device in date notification";
static NSString *const ADD_DEVICE_TRACE_NOTIFICATION = @"add device trace notification";

@class DeviceTraceModel;

@interface DeviceTraceService : BaseService

- (void)findDeviceTraceWithUser:(UsersModel *)user withDate:(NSString *)dateStr;

- (void)addDeviceTraceInfoWithDeviceTraceModel:(DeviceTraceModel *)deviceModel;

@end
