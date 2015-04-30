//
//  CommonHelper.h
//  onestong
//
//  Created by 王亮 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject
+(void)postNotification:(NSString *)notificationName userInfo:(NSDictionary *)userInfo;
+(void)alert:(NSString *)message;
+ (NSString *)md5:(NSString *)str;
@end
