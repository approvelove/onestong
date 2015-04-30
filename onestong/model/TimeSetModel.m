//
//  TimeSetModel.m
//  onestong
//
//  Created by 李健 on 14-6-5.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "TimeSetModel.h"

@implementation TimeSetModel
@synthesize timeId,startTime,endTime,creator,updateTime,updator,vaild,remark;

- (TimeSetModel *)fromDictionary:(NSDictionary *)obj
{
    if (obj[@"cr"]) {
        self.creator = obj[@"cr"];
    }
    if (obj[@"et"]) {
        self.endTime = obj[@"et"];
    }
    if (obj[@"id"]) {
        self.timeId = obj[@"id"];
    }
    if (obj[@"st"]) {
        self.startTime = obj[@"st"];
    }
    if (obj[@"up"]) {
        self.updator = obj[@"up"];
    }
    if (obj[@"ut"]) {
        self.updateTime = obj[@"ut"];
    }
    if (obj[@"va"]) {
        self.vaild = obj[@"va"];
    }
    
    return self;
}
@end
