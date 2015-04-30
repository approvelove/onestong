//
//  DepartmentsService.m
//  onestong
//
//  Created by 王亮 on 14-4-28.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DepartmentsService.h"
#import "CommonHelper.h"
#import "CDDepartmentDAO.h"

@implementation DepartmentsService
-(void)findOwnDepartments
{
    NSString * departmentsUrl = [NSString stringWithFormat:@"%@departments/own/%@/%@",BASE_URL, [self getEmail],[self getToken]];
    [[AFHTTPRequestOperationManager manager]GET:departmentsUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrDepartments =responseObject[@"resultData"];
            if (arrDepartments) {
                [arrDepartments enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    DepartmentModel *department = [[DepartmentModel alloc]init];
                    [resultArr addObject:[department fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_OWN_DEPARTMENTS_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_OWN_DEPARTMENTS_NOTIFICATION userInfo:nil];
    }];
}

-(void)findLowerDepartments:(NSString *)parentId
{
    NSString * departmentsUrl = [NSString stringWithFormat:@"%@departments/lower/%@/%@",BASE_URL, parentId, [self getToken]];
    [[AFHTTPRequestOperationManager manager]GET:departmentsUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrDepartments =responseObject[@"resultData"];
            if (arrDepartments){
                [arrDepartments enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    DepartmentModel *department = [[DepartmentModel alloc]init];
                    [resultArr addObject:[department fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_LOWER_DEPARTMENTS_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_LOWER_DEPARTMENTS_NOTIFICATION userInfo:nil];
    }];
}

- (void)updateDepartment:(DepartmentModel *)department
{
    NSString *addDepartmentURL = [NSString stringWithFormat:@"%@departments/update/%@",BASE_URL,[self getToken]];
    NSDictionary *tempDict = @{@"id":department.departmentId,@"ownerEmail":department.departmentOwner?department.departmentOwner:@"",@"parentId":department.parentId,@"parentName":department.parentName,@"name":department.departmentName};
    [[AFHTTPRequestOperationManager manager] POST:addDepartmentURL parameters:tempDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        DepartmentModel *dept = [[DepartmentModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *deptDic =responseObject[@"resultData"];
            if (deptDic){
                CDDepartmentDAO * deptDAO = [[CDDepartmentDAO alloc]init];
                [deptDAO update:deptDic];
                [dept fromDictionary:deptDic];
            }
        }
        [CommonHelper postNotification:UPDATE_DEPARTMENT_NOTIFICAITON userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":dept}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:UPDATE_DEPARTMENT_NOTIFICAITON userInfo:nil];
    }];
}

- (void)addDepartment:(DepartmentModel *)department
{
    NSString *addDepartmentURL = [NSString stringWithFormat:@"%@departments/%@",BASE_URL,[self getToken]];
    NSDictionary *tempDict = @{@"name":department.departmentName,@"ownerEmail":department.departmentOwner?department.departmentOwner:@"",@"parentId":department.parentId,@"parentName":department.parentName};
    [[AFHTTPRequestOperationManager manager] POST:addDepartmentURL parameters:tempDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        DepartmentModel *dept = [[DepartmentModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *deptDic =responseObject[@"resultData"];
            if (deptDic){
                CDDepartmentDAO * deptDAO = [[CDDepartmentDAO alloc]init];
                [deptDAO save:deptDic];
                [dept fromDictionary:deptDic];
            }
        }
        [CommonHelper postNotification:ADD_DEPARTMENT_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":dept}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:ADD_DEPARTMENT_NOTIFICATION userInfo:nil];
    }];
}

- (void)deleteDepartment:(DepartmentModel *)department
{
    NSString *deleteDepartmentURL = [NSString stringWithFormat:@"%@departments/delete/%@",BASE_URL,[self getToken]];
    NSDictionary *tempDict = @{@"id":department.departmentId};
    [[AFHTTPRequestOperationManager manager] POST:deleteDepartmentURL parameters:tempDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
            [deptDAO deleteById:department.departmentId];
        }
        [CommonHelper postNotification:DELETE_DEPARTMENT_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":@""}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:DELETE_DEPARTMENT_NOTIFICATION userInfo:nil];
    }];
}



//报表部分  type 1--考勤 2--拜访
- (void)getDepartmentEventChartWithDepartmentId:(NSString *)departmentId beginTime:(NSString *)beginTime endTime:(NSString *)endTime checkType:(CHECK_TYPE)type
{
    NSString *getChartURL = [NSString stringWithFormat:@"%@charts/%@",BASE_URL,[self getToken]];
    NSDictionary *postDict = @{@"beginDate":beginTime,@"endDate":endTime,@"departmentId":departmentId,@"type":@(type)};
    [[AFHTTPRequestOperationManager manager] GET:getChartURL parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"部门考勤报表 = %@",responseObject);
        switch (type) {
            case CHECK_TYPE_ATTENDANCE:
                [CommonHelper postNotification:GET_DEPARTMENT_ATTENDANCECHART_MONTH_NOTIFICATION userInfo:responseObject];
                break;
                
            case CHECK_TYPE_VISIT:
                [CommonHelper postNotification:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION userInfo:responseObject];
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        switch (type) {
            case CHECK_TYPE_ATTENDANCE:
                [CommonHelper postNotification:GET_DEPARTMENT_ATTENDANCECHART_MONTH_NOTIFICATION userInfo:nil];
                break;
                
            case CHECK_TYPE_VISIT:
                [CommonHelper postNotification:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION userInfo:nil];
                break;
        }
    }];
}

//- (void)getDepartmentMonthVisitChartWithDepartmentId:(NSString *)departmentId andDate:(NSString *)date
//{
//    NSString *getChartURL = [NSString stringWithFormat:@"%@visitcharts/%@/%@/%@",BASE_URL,date,departmentId,[self getToken]];
//    [[AFHTTPRequestOperationManager manager] GET:getChartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"部门外访报表 = %@",responseObject);
//        [CommonHelper postNotification:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION userInfo:responseObject];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [CommonHelper postNotification:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION userInfo:nil];
//    }];
//}
@end
