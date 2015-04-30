//
//  TimeSetSerivce.h
//  onestong
//
//  Created by 李健 on 14-6-5.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseService.h"
@class TimeSetModel;


static NSString *const NOTIFICATION_FIND_ALL_TIME = @"find all time all notification";
static NSString *const NOTIFICATION_ADD_TIME = @"add time notification";

@interface TimeSetSerivce : BaseService

- (void)findAllWorkTime;

//更新上下班时间接口
- (void)addTimeInfoWithTimeSetModel:(TimeSetModel *)timeModel;

@end
