//
//  VerifyHelper.m
//  onestong
//
//  Created by 王亮 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "VerifyHelper.h"

@implementation VerifyHelper
+(BOOL)isEmpty:(NSString *)field
{
    if (nil == field || NULL == field) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *trimmedString = [field stringByTrimmingCharactersInSet:set];
    if ([trimmedString isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
@end
