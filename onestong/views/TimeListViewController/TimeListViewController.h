//
//  TimeListViewController.h
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, EVENTTYPE) {
    EVENTTYPE_VISIT,
    EVENTTYPE_ATTENDANCE,
    EVENTTYPE_DEVICE_MAPPATH,
    EVENTTYPE_EVENT_MAPPATH
};

@class UsersModel;

@interface TimeListViewController : BaseViewController

@property (nonatomic, strong) UsersModel *user;
@property (nonatomic) EVENTTYPE eventType;
@end
