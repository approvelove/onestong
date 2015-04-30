//
//  DataUpdateService.m
//  onestong
//
//  Created by 王亮 on 14-5-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DataUpdateService.h"
#import "CDDepartmentDAO.h"
#import "CommonHelper.h"
#import "CDUserDAO.h"

@implementation DataUpdateService
-(void)updateDepartmentsData
{
    NSString * updateDepartmentsDatasUrl = [NSString stringWithFormat:@"%@departments/%@",BASE_URL, [self getToken]];
    
    [[AFHTTPRequestOperationManager manager]GET:updateDepartmentsDatasUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary * responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrDepartments =responseObject[@"resultData"];
            if (arrDepartments) {
                CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc]init];
                [deptDAO clearData];
                [arrDepartments enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    if (![deptDAO save:obj]) {
                        *stop = YES;
                    };
                }];
            }
        }
        [CommonHelper postNotification:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":@"success"}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}

-(void)updateUsersData
{
    NSString * updateUsersDatasUrl = [NSString stringWithFormat:@"%@users/%@",BASE_URL,[self getToken]];
    [[AFHTTPRequestOperationManager manager]GET:updateUsersDatasUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary * responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrUsers =responseObject[@"resultData"];
            if (arrUsers) {
                CDUserDAO *userDAO = [[CDUserDAO alloc]init];
                [userDAO clearData];
                [arrUsers enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    if (![userDAO save:obj]) {
                        *stop = YES;
                    };
                }];
            }
        }
        [CommonHelper postNotification:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":@"success"}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}
@end
