//
//  DepartmentListCell.h
//  Transaction
//
//  Created by 李健 on 14-1-19.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDUser;
@class CDDepartment;

@interface MapPathChartDepartmentCell : UITableViewCell

@property (nonatomic, copy) NSString *cellClass;   //类别：人／部门
@property (nonatomic, copy) NSString *cellName;   //人名
@property (nonatomic, copy) NSString *personID;  //人的ID
@property (nonatomic, copy) NSString *subDepartmentID;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *personEmail;
@property (nonatomic, weak) IBOutlet UILabel *firstLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondLabel;
@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDDepartment *departmentModel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;

+ (MapPathChartDepartmentCell *)loadFromNib;

@end
