//
//  DepartmentListCell.m
//  Transaction
//
//  Created by 李健 on 14-1-19.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "DepartmentListCell.h"
@interface DepartmentListCell()
{
}
@end
@implementation DepartmentListCell
@synthesize cellClass,cellName,personID,subDepartmentID,position,personEmail,firstLabel,secondLabel,leftImageView,user,subTitleLabel,indexpathNum;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    [super handlePan:recognizer];
    self.accessoryType = UITableViewCellAccessoryNone;
}


+ (DepartmentListCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DepartmentListCell" owner:self options:nil] objectAtIndex:0];
}
@end
