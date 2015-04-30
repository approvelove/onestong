//
//  EventsBoxViewController.h
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

typedef NS_ENUM(NSInteger, Box) {
    Box_owner,
    Box_Other,
    Box_Other_Mapchart
};


#import "BaseViewController.h"
@class UsersModel;

@interface EventsBoxViewController : BaseViewController

@property(nonatomic)Box currentBox;
@property(nonatomic)UsersModel *currentUser;
@end
