//
//  VersionCheckService.m
//  onestong
//
//  Created by 李健 on 14-6-12.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "VersionCheckService.h"
#import "CommonHelper.h"
#import "VersionModel.h"

@implementation VersionCheckService

- (void)checkVersion
{
    NSString *urlStr = [NSString stringWithFormat:@"%@version/ios",BASE_URL];
    [[AFHTTPRequestOperationManager manager] GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *dicUsers =responseObject[@"resultData"];
            if (dicUsers) {
                VersionModel *versionModel = [VersionModel fromDictionary:dicUsers];
                [resultArr addObject:versionModel];
            }
        }
        [CommonHelper postNotification:NOTIFICATION_VERSION_CHECK userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:NOTIFICATION_VERSION_CHECK userInfo:nil];
    }];
}
@end
