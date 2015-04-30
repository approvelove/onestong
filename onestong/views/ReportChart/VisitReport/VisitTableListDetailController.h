//
//  VisitTableListDetailController.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "BaseViewController.h"

@interface VisitTableListDetailController : BaseViewController

@property (nonatomic, strong) NSString *selectedUserId;
@property (nonatomic, assign) NSInteger selectMonth;

@property (nonatomic, strong) NSString *superBeginDateStr;
@property (nonatomic, strong) NSString *superEndDateStr;
@end
