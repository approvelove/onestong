//
//  CDResourceInfoDAO.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResourceInfoModel,CDResourceInfo;

@interface CDResourceInfoDAO : NSObject
+ (BOOL)save:(ResourceInfoModel *)model;
+ (CDResourceInfo *)findById:(NSString *)eventId isSignIn:(BOOL)isSignIn;
+ (BOOL)clearData;
+ (BOOL)deleteById:(NSString *)eventId isSignIn:(BOOL)isSignIn;

+ (BOOL)update:(ResourceInfoModel *)model isSignIn:(BOOL)isSignIn;
@end
