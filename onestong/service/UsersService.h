//
//  UsersService.h
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "UsersModel.h"
#import "BaseService.h"

static NSString *const LOGIN_COMPELETE_NOTIFICATION = @"loginCompleteNotification";
static NSString *const RESETPASSWORD_COMPELETE_NOTIFICATION = @"resetPasswordCompleteNotification";
static NSString *const MODIFYPASSWORD_COMPLETE_NOTIFICATION = @"modifyPasswordCompleteNotification";
static NSString *const EDITUSER_COMPLETE_NOTIFICATION = @"editUserCompleteNotification";
static NSString *const FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION = @"findDepartmentUsersCompleteNotification";
static NSString *const DELETE_USER_COMPLETE_NOTIFICATION = @"delete user complete notification";
static NSString *const UPDATE_PERSONAL_USER_INFO_NOTIFICATION = @"update personal user infomation notification";
static NSString *const MANAGE_USER_INFO_NOTIFICATION = @"manage user info notification";
static NSString *const ADD_USER_INFO_NOTIFICATION = @"add user info notification";
static NSString *const GET_USER_VISIT_CHART_MONTH_NOTIFICATION = @"get user visit chart month notification";
static NSString *const GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION = @"get user attendance chart month notification";
static NSString *const UNLOCK_ACOUNT_NOTIFICATION = @"unlock acount notification";


typedef NS_ENUM(NSInteger, CHART_TYPE) {
    CHART_TYPE_ATTENDANCE = 1,
    CHART_TYPE_VISIT
};

@interface UsersService :BaseService

-(void)login:(UsersModel *)user;

-(void)resetPasswordWithUserId:(NSString *)userId;

-(void)modifyPassword:(UsersModel *)user;

/**
 *	@brief	编辑个人信息
 *
 *	@param 	user   登录用户
 *
 *	@return	nil
 */
-(void)editUserInfo:(UsersModel *)user;

/**
 *	@brief	查找某部门用户
 *
 *	@param 	departmentId 	部门ID
 *
 *	@return nil
 */
-(void)findDepartmentUsers:(NSString *)departmentId;

- (void)deleteUser:(UsersModel *)user;

- (void)updateUserInfo:(UsersModel *)user;

/**
 *	@brief	管理用户信息(该接口主要在添加用户和管理用户界面编辑用户信息时使用)
 *
 *	@param 	user 	当前用户
 *
 *	@return	nil
 */
- (void)ManageUserInfo:(UsersModel *)user;


/**
 *	@brief	添加一个新用户
 *
 *	@param 	user 	待添加的用户信息
 *
 *	@return	nil
 */
- (void)addUserInfo:(UsersModel *)user;


//- (void)getUserMonthAttendanceChartWithUserId:(NSString *)userId andDate:(NSString *)date;
//- (void)getUserMonthVisitChartWithUserId:(NSString *)userId andDate:(NSString *)date;


/**
 *	@brief	获取某用户某段时间内的报表（依据类型不同分为考勤和事件报表）
 *
 *	@param 	userId 	待查询的用户ID
 *	@param 	beginDate 	开始时间
 *	@param 	endDate 	结束时间
 *	@param 	type 	报表类型
 *
 *	@return	nil
 */
- (void)getUserChartsWithUserId:(NSString *)userId
                      beginDate:(NSString *)beginDate
                        endDate:(NSString *)endDate
                      chartType:(CHART_TYPE)type;


/**
 *	@brief	解锁账户绑定
 *
 *	@param 	userId 	待解锁的用户ID
 *
 *	@return	nil
 */
- (void)unlockAcountWithUserId:(NSString *)userId;

@end
