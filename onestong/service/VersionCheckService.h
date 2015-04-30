//
//  VersionCheckService.h
//  onestong
//
//  Created by 李健 on 14-6-12.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseService.h"

static NSString * const NOTIFICATION_VERSION_CHECK = @"notification version check";

@interface VersionCheckService : BaseService
- (void)checkVersion;
@end
