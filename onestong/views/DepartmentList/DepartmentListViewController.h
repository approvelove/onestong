//
//  DepartmentListViewController.h
//  onestong
//
//  Created by 李健 on 14-5-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"
static NSString * const NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST = @"selected department in list";
static NSString * const NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST_CANCEL = @"selected department in list cancel";

typedef NS_ENUM(NSInteger, FIND_DATA) {
    FIND_DATA_ALL = 1,
    FIND_DATA_BY_ID
};
@interface DepartmentListViewController : BaseViewController

@property (nonatomic, strong) NSString *departmentId;
@property (nonatomic, strong) NSString *ownerDepartmentId;
@property (nonatomic, strong) NSString *constFatherDepartmentId;

@property (nonatomic) FIND_DATA findRange;
@end
