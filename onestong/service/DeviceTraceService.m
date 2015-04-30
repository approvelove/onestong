//
//  DeviceTraceService.m
//  onestong
//
//  Created by 李健 on 14-6-14.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DeviceTraceService.h"
#import "UsersModel.h"
#import "CommonHelper.h"
#import "DeviceTraceModel.h"

@implementation DeviceTraceService

- (void)findDeviceTraceWithUser:(UsersModel *)user withDate:(NSString *)dateStr
{
    NSString *urlStr = [NSString stringWithFormat:@"%@deviceTraces/%@/%@/%@",BASE_URL,user.userId,dateStr,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrLocation =responseObject[@"resultData"];
            if (arrLocation) {
                [arrLocation enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    [resultArr addObject:[DeviceTraceModel fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_DEVICE_IN_DATE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_DEVICE_IN_DATE_NOTIFICATION userInfo:nil];
    }];
}


- (void)addDeviceTraceInfoWithDeviceTraceModel:(DeviceTraceModel *)deviceModel
{
    NSString *urlStr = [NSString stringWithFormat:@"%@deviceTraces/%@",BASE_URL,[self getToken]];
    NSDictionary *postDict = @{@"lo":[NSString stringWithFormat:@"%f",deviceModel.longtitude],@"la":[NSString stringWithFormat:@"%f",deviceModel.latitude],@"userId":[self getOwnId],@"lc":deviceModel.location};
    [[AFHTTPRequestOperationManager manager] POST:urlStr parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"😄 设备轨迹发送成功了=%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"😭 设备轨迹发送失败了 ＝ %@",error.localizedDescription);
    }];
}
@end
