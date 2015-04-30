//
//  TableListDetailViewController.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "BaseViewController.h"

@interface TableListDetailViewController : BaseViewController
@property (nonatomic, strong) NSString *selecteduserId;
@property (nonatomic) NSInteger selectMonth;

@property (nonatomic, strong) NSString *superBeginDateStr;
@property (nonatomic, strong) NSString *superEndDateStr;
@property (nonatomic, strong) NSString *rightItemTitle;
@property (nonatomic, strong) NSString *navTitleTimeStr;

@end
