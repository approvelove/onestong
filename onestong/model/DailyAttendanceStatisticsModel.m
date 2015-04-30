//
//  DailyAttendanceStatisticsModel.m
//  onestong
//
//  Created by 王亮 on 14-4-29.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DailyAttendanceStatisticsModel.h"
#import "TimeHelper.h"

@implementation DailyAttendanceStatisticsModel
@synthesize createTime, email, signDate, signInNum, signOutNum, statisticsId;
-(DailyAttendanceStatisticsModel *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"id"]) {
        self.statisticsId = obj[@"id"];
    }
    
    if (obj[@"da"]) {
        self.signDate = obj[@"da"];
    }
    
    if ([obj[@"si"] isKindOfClass:[NSNumber class]]) {
        self.signInNum = [obj[@"si"] intValue];
    }
    else if ([obj[@"si"] isKindOfClass:[NSDictionary class]]){
        long long timeNum = [obj[@"si"][@"ti"] longLongValue];
        NSDateComponents *comps = [TimeHelper convertTimeToDateComponents:timeNum];
        self.signDate = [NSString stringWithFormat:@"%.2d-%.2d-%.2d",comps.year,comps.month,comps.day];
    }
        
    if ([obj[@"so"] isKindOfClass:[NSNumber class]]) {
        self.signOutNum = [obj[@"so"] intValue];
    }
    
    if (obj[@"em"]) {
        self.email = obj[@"em"];
    }
    
    if (obj[@"ct"]) {
        self.createTime = [obj[@"ct"] longLongValue];
    }
    return self;
}
@end