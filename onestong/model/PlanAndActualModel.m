//
//  PlanAndActualModel.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "PlanAndActualModel.h"

@implementation PlanAndActualModel
@synthesize beginAddress,beginTime,endAddress,endTime,eventId,isPlan;

-(PlanAndActualModel *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"ba"]) {
        self.beginAddress = obj[@"ba"];
    }
    if (obj[@"bt"]) {
        self.beginTime = [obj[@"bt"] longLongValue];
    }
    if (obj[@"ea"]) {
        self.endAddress = obj[@"ea"];
    }
    if (obj[@"et"]) {
        self.endTime = [obj[@"et"]longLongValue];
    }
    
    return self;
}
@end