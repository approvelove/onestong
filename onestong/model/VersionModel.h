//
//  VersionModel.h
//  onestong
//
//  Created by 李健 on 14-6-12.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionModel : NSObject

@property (nonatomic , strong) NSString *versionCode;
@property (nonatomic) NSInteger versionUpdateLevel;  //0 可以不更新 1 必须更新
@property (nonatomic, strong) NSString *downLoadURL; //新版本下载地址
@property (nonatomic, strong) NSString *content; //内容
@property (nonatomic, strong) NSString *versionDescription;

+ (VersionModel *)fromDictionary:(NSDictionary *)obj;
@end
