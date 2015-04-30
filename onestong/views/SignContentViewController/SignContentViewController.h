//
//  SignContentViewController.h
//  onestong
//
//  Created by 李健 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

//签到 签退内容


typedef NS_ENUM(NSInteger, MAINFOUNDATION) {
    MAINFOUNDATION_SING_IN,
    MAINFOUNDATION_SING_OUT,
    MAINFOUNDATION_EDIT,
    MAINFOUNDATION_ATTENDANCE_SIGN_IN,
    MAINFOUNDATION_ATTENDANCE_SIGN_OUT,
};

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
@class EventModel;

@interface SignContentViewController :BaseViewController
@property (nonatomic,assign) MAINFOUNDATION mainFoundation;

@property (nonatomic, strong) EventModel *currentEventModel; //need complete when signOut;
@property (nonatomic) CLLocationCoordinate2D signedIncoordinate; //need complete when signOut;

@property (nonatomic, assign) BOOL vaildAttendanceSignIn;
@end
