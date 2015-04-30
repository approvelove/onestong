//
//  OrganizeViewController.h
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

typedef NS_ENUM(NSInteger, CONTROLLER) {
    CONTROLLER_VISIT,
    CONTROLLER_ATTENDANCE
};

#import "BaseViewController.h"

@interface DepartmentOnlyViewController : BaseViewController
@property (nonatomic, copy) NSString *superDepartmentID; //子部门ID
@property (nonatomic, strong) NSString *authDepartmentId;

@property (nonatomic) CONTROLLER controllerMeothod;
@end
