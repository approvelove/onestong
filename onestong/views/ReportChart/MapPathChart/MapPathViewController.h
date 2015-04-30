//
//  MapPathViewController.h
//  onestong
//
//  Created by 李健 on 14-6-9.
//  Copyright (c) 2014年 王亮. All rights reserved.
//


typedef NS_ENUM(NSInteger, SHOWPOINT) {
    SHOWPOINT_EVENT,
    SHOWPOINT_DEVICE
};

#import "BaseViewController.h"
@class UsersModel;

@interface MapPathViewController : BaseViewController

@property (nonatomic, copy) NSString *showDate;
@property (nonatomic, strong) UsersModel *currentUser;
@property (nonatomic) SHOWPOINT currentShow;

@end
