//
//  SignDetailViewController.h
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, SHOWEVENT) {
    SHOWEVENT_ALL,
    SHOWEVENT_VISIT,
    SHOWEVENT_ATTENDANCE
};

@class UsersModel;

@interface SignDetailViewController :  BaseViewController
@property (nonatomic, copy) NSString *showDate;

@property (nonatomic, strong) UsersModel *currentUser;
@property (nonatomic, assign) SHOWEVENT eventMethod;
@property (nonatomic, strong) NSArray *dateArray;

@end
