//
//  DepartmentListCell.h
//  Transaction
//
//  Created by 李健 on 14-1-19.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "DAContextMenuCell.h"
@class UsersModel;


@interface DepartmentListCell : DAContextMenuCell

@property (nonatomic, copy) NSString *cellClass;   //类别：人／部门
@property (nonatomic, copy) NSString *cellName;   //人名
@property (nonatomic, copy) NSString *personID;  //人的ID
@property (nonatomic, copy) NSString *subDepartmentID;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *personEmail;
@property (nonatomic, weak) IBOutlet UILabel *firstLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondLabel;
@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, strong) NSIndexPath *indexpathNum;

//@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, strong) UsersModel *user;

+ (DepartmentListCell *)loadFromNib;

@end
