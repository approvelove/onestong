//
//  SubSignDetailViewController.h
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@class UsersModel;

@interface SubSignDetailViewController :  BaseViewController
@property (nonatomic, copy) NSString *showDate;
@property (nonatomic, strong) UsersModel *currentUser;
@property (nonatomic, strong) NSArray *personAryArray;
@property (nonatomic, strong) NSArray *dateAry;

@end
