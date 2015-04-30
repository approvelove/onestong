//
//  DataUpdateService.h
//  onestong
//
//  Created by 王亮 on 14-5-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//
//该模块儿主要用于数据库的更新和同步，是提供离线数据的来源


#import <Foundation/Foundation.h>
#import "BaseService.h"

static NSString * const DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION = @"departments data update complete notification";
static NSString * const USERS_DATA_UPDATE_COMPLETE_NOTIFICATION = @"users data update complete notification";
@interface DataUpdateService : BaseService

-(void)updateDepartmentsData;

-(void)updateUsersData;
@end
