//
//  DailyAttendanceStatisticsModel.h
//  onestong
//
//  Created by 王亮 on 14-4-29.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyAttendanceStatisticsModel : NSObject
@property (copy, nonatomic)NSString *statisticsId; //id
@property (copy, nonatomic)NSString *signDate;//签到日期da
@property (nonatomic)int signInNum;//签到日期si
@property (nonatomic)int signOutNum;//签退日期so
@property (copy, nonatomic)NSString *email;//签到人邮箱em
@property (nonatomic)long long createTime;//创建时间ct

-(DailyAttendanceStatisticsModel *)fromDictionary: (NSDictionary *)obj;
@end
