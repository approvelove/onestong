//
//  VersionModel.m
//  onestong
//
//  Created by 李健 on 14-6-12.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "VersionModel.h"

@implementation VersionModel
@synthesize versionCode,versionUpdateLevel,downLoadURL,content,versionDescription;

+ (VersionModel *)fromDictionary:(NSDictionary *)obj
{
    VersionModel *temp = [[VersionModel alloc] init];
    if (obj) {
        temp.versionCode = obj[@"co"];
        temp.versionUpdateLevel = [obj[@"iu"] integerValue];
        temp.downLoadURL = obj[@"ur"];
        temp.content = obj[@"ct"];
        temp.versionDescription = obj[@"de"];
    }
    return temp;
}
@end
