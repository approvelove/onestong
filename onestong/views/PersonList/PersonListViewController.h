//
//  PersonListViewController.h
//  onestong
//
//  Created by 李健 on 14-5-27.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"
static NSString * const NOTIFICATION_SELECTED_USER_IN_LIST = @"selected user in list";
static NSString * const NOTIFICATION_SELECTED_USER_IN_LIST_CANCEL = @"selected user in list cancel";

@interface PersonListViewController : BaseViewController
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *ownerUserId;
@property (nonatomic, strong) NSString *constFatherDepartmentId;
@end
