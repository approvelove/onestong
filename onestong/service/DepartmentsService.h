//
//  DepartmentsService.h
//  onestong
//
//  Created by 王亮 on 14-4-28.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"
#import "DepartmentModel.h"

typedef NS_ENUM(NSInteger, CHECK_TYPE) {
    CHECK_TYPE_ATTENDANCE = 1,
    CHECK_TYPE_VISIT
};



static NSString * const FIND_OWN_DEPARTMENTS_NOTIFICATION = @"findOwnDepartmentsNotification";
static NSString * const FIND_LOWER_DEPARTMENTS_NOTIFICATION = @"findLowerDepartmentsNotification";
static NSString * const ADD_DEPARTMENT_NOTIFICATION = @"add department notification";
static NSString * const DELETE_DEPARTMENT_NOTIFICATION = @"delete department notification";
static NSString * const UPDATE_DEPARTMENT_NOTIFICAITON = @"update department notification";
static NSString * const GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION = @"get department visit chart month notification";
static NSString * const GET_DEPARTMENT_ATTENDANCECHART_MONTH_NOTIFICATION = @"get department attendance chart month notification";


@interface DepartmentsService :BaseService
-(void)findOwnDepartments;
-(void)findLowerDepartments:(NSString *)parentId;
-(void)addDepartment:(DepartmentModel *)department;
- (void)deleteDepartment:(DepartmentModel *)department;
- (void)updateDepartment:(DepartmentModel *)department;

//获取部门某时间段内事件报表（依据事件类型不同分别返回考勤和拜访报表）
- (void)getDepartmentEventChartWithDepartmentId:(NSString *)departmentId
                                      beginTime:(NSString *)beginTime
                                        endTime:(NSString *)endTime
                                      checkType:(CHECK_TYPE)type;
//- (void)getDepartmentMonthVisitChartWithDepartmentId:(NSString *)departmentId andDate:(NSString *)date;
@end
