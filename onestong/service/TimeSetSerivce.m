//
//  TimeSetSerivce.m
//  onestong
//
//  Created by 李健 on 14-6-5.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "TimeSetSerivce.h"
#import "CommonHelper.h"
#import "TimeSetModel.h"

@implementation TimeSetSerivce

- (void)findAllWorkTime
{
    NSString *timeURL = [NSString stringWithFormat:@"%@worktimes/%@",BASE_URL,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:timeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrUsers =responseObject[@"resultData"];
            if (arrUsers) {
                [arrUsers enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    TimeSetModel *statistics = [[TimeSetModel alloc]init];
                    [resultArr addObject:[statistics fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:NOTIFICATION_FIND_ALL_TIME userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:NOTIFICATION_FIND_ALL_TIME userInfo:nil];
    }];
}

- (void)addTimeInfoWithTimeSetModel:(TimeSetModel *)timeModel
{
    NSString *timeURL = [NSString stringWithFormat:@"%@worktime/update/%@",BASE_URL,[self getToken]];
    NSDictionary *postData = @{@"id":timeModel.timeId,@"startTime":timeModel.startTime,@"endTime":timeModel.endTime};
    [[AFHTTPRequestOperationManager manager] POST:timeURL parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [CommonHelper postNotification:NOTIFICATION_ADD_TIME userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:NOTIFICATION_ADD_TIME userInfo:nil];
    }];
}
@end
