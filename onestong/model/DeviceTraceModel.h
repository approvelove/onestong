//
//  DeviceTraceModel.h
//  onestong
//
//  Created by 李健 on 14-6-14.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTraceModel : NSObject

@property (nonatomic) double longtitude;   //lo
@property (nonatomic) double latitude;   //la
@property (nonatomic ,strong) NSString *location;   //lc
@property (nonatomic, strong) NSString *userId;   //ud
@property (nonatomic) long long createTime;  //ct
@property (nonatomic, strong) NSString *date;  //da


+ (DeviceTraceModel *)fromDictionary:(NSDictionary *)obj;
@end
