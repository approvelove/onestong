//
//  OrganizeViewController.h
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DAContextMenuTableViewController.h"

@interface DepartmentAndUserViewController : DAContextMenuTableViewController
@property (nonatomic, copy) NSString *superDepartmentID; //子部门ID
@property (nonatomic, strong) NSString *constFatherDepartmentId;
@end
