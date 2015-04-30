//
//  NewDepartmentCell.h
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDUser;
@class CDDepartment;
#import "OSTButton.h"

@interface NewDepartmentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *vLine;
@property (nonatomic, weak) IBOutlet UIImageView *bottomLine;
@property (nonatomic, weak) IBOutlet OSTButton *selectionButton;
@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDDepartment *department;

+ (NewDepartmentCell *)loadFromNib;
@end
