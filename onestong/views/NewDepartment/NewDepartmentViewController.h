//
//  NewDepartmentViewController.h
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "FormViewController.h"
@class CDDepartment;
@interface NewDepartmentViewController : FormViewController

@property (nonatomic, strong) CDDepartment *currentDepartmentADO, *superDepartment;
@property (nonatomic, weak) IBOutlet UIButton *btnSelectSuperDepartment;
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic) BOOL needFindPersonById;
@property (nonatomic) BOOL needFindDepartmentById;
@property (nonatomic, strong) NSString *constFatherDepartmentId;

@end
