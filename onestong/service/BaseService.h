//
//  BaseService.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersModel.h"
#import "AFHTTPRequestOperationManager.h"

//static NSString *const BASE_URL = @"http://192.168.9.232:8080/onestong/restapi/";
//static NSString *const BASE_URL = @"http://appsrv.onestong.cn:8808/onestong/restapi/";
static NSString *const BASE_URL = @"http://appsrv1.onestong.com:18080/onestong/restapi/";
@interface BaseService :NSObject
-(NSString *)getOwnId;
-(NSString *)getToken;
-(UsersModel *)getCurrentUser;
-(NSString *)getEmail;
-(NSString *)getPassWord;
-(NSString *)getDeviceId;
+ (BOOL)checkReachability;
@end
