//
//  NewPersonViewController.h
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "FormViewController.h"
@class CDUser;
@class CDDepartment;

@interface NewPersonViewController : FormViewController

@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDDepartment *superDepartment;

@property (nonatomic) BOOL needFindPersonById;
@property (nonatomic) BOOL needFindDepartmentById;

@property (nonatomic, strong) NSString *constFatherDepartmentId;

@end
