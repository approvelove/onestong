//
//  OSTButton.h
//  onestong
//
//  Created by 李健 on 14-7-3.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDDepartment;
@class EventModel;

@interface OSTButton : UIButton

@property (nonatomic, strong) NSString *btnId;
@property (nonatomic, strong) CDDepartment *department;
@property (nonatomic, strong) EventModel *event;

@end
