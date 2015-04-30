//
//  DailyAttendanceStatisticsService.m
//  onestong
//
//  Created by 王亮 on 14-4-29.
//  Copyright (c) 2014年 王亮. All rights reserved.
///statistics/{li}/{sk}/{email}

#import "DailyAttendanceStatisticsService.h"
#import "CommonHelper.h"

@implementation DailyAttendanceStatisticsService

-(void)findOwnStatistics:(NSString *)userID andPageNum:(int)page
{
    NSString * departmentUsersUrl = [NSString stringWithFormat:@"%@statistics/%d/%d/%@/%@",BASE_URL, 10, (page-1)*10,userID,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:departmentUsersUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrUsers =responseObject[@"resultData"];
            if (arrUsers) {
                [arrUsers enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    DailyAttendanceStatisticsModel *statistics = [[DailyAttendanceStatisticsModel alloc]init];
                    [resultArr addObject:[statistics fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_OWN_STATISTICS_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_OWN_STATISTICS_NOTIFICATION userInfo:nil];
    }];
}

-(void)findOwnSignStatistics:(NSString *)userID andPageNum:(int)page
{
    NSString * departmentUsersUrl = [NSString stringWithFormat:@"%@events/signlist/%d/%d/%@/%@",BASE_URL, 10, (page-1)*10,userID,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:departmentUsersUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrUsers =responseObject[@"resultData"];
            if (arrUsers) {
                [arrUsers enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    DailyAttendanceStatisticsModel *statistics = [[DailyAttendanceStatisticsModel alloc]init];
                    [resultArr addObject:[statistics fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_OWN_STATISTICS_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_OWN_STATISTICS_NOTIFICATION userInfo:nil];
    }];
}
@end
