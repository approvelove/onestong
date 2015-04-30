//
//  BaseService.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseService.h"
#import "AFNetworkReachabilityManager.h"

@implementation BaseService
-(NSString *)getOwnId
{
    UsersModel *user = [self getCurrentUser];
    return (nil == user) ? @"-1" : user.userId;
}

-(NSString *)getToken
{
    UsersModel *user = [self getCurrentUser];
    return (nil == user) ? @"-1" : user.token;
}

-(NSString *)getEmail
{
    UsersModel *user = [self getCurrentUser];
    return (nil == user) ? @"" : user.email;
}

-(NSString *)getPassWord
{
    UsersModel *user = [self getCurrentUser];
    return (nil == user) ? @"" : user.password;
}

-(NSString *)getDeviceId
{
    UsersModel *user = [self getCurrentUser];
    return (nil == user) ? @"" : user.deviceId;
}

-(UsersModel *)getCurrentUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [defaults objectForKey:@"currentUser"];
    if (userData) {
        return (UsersModel *)[NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }else{
        return nil;
    }
}

+ (BOOL)checkReachability
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (!data || data.length == 0) {
        return NO;
    }
    return YES;
}
@end
