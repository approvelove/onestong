//
//  OrganizeViewController.h
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DAContextMenuTableViewController.h"

typedef NS_ENUM(NSInteger, ORGANIZEORMANAGEMENTBACKGROUND) {
    ORGANIZEORMANAGEMENTBACKGROUND_ORGANIZE,
    ORGANIZEORMANAGEMENTBACKGROUND_MANAGEMENTBACKGROUND
};

@interface OrganizeViewController : DAContextMenuTableViewController

@property (nonatomic, assign) ORGANIZEORMANAGEMENTBACKGROUND organizeMethod;
@property (nonatomic, copy) NSString *subDepartmentID; //子部门ID
@end
