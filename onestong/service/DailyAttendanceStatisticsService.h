//
//  DailyAttendanceStatisticsService.h
//  onestong
//
//  Created by 王亮 on 14-4-29.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseService.h"
#import "DailyAttendanceStatisticsModel.h"

static NSString * const FIND_OWN_STATISTICS_NOTIFICATION = @"findOwnStatisticsNotification";

@interface DailyAttendanceStatisticsService : BaseService


- (void)findOwnStatistics:(NSString *)email andPageNum:(int)page;

-(void)findOwnSignStatistics:(NSString *)userID andPageNum:(int)page;
@end
