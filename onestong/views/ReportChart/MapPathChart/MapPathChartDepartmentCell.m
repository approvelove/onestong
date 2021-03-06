//
//  DepartmentListCell.m
//  Transaction
//
//  Created by 李健 on 14-1-19.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "MapPathChartDepartmentCell.h"
@interface MapPathChartDepartmentCell()
{
}
@end
@implementation MapPathChartDepartmentCell
@synthesize cellClass,cellName,personID,subDepartmentID,position,personEmail,firstLabel,secondLabel,leftImageView,user,departmentModel,subTitleLabel;

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


+ (MapPathChartDepartmentCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"MapPathChartDepartmentCell" owner:self options:nil] objectAtIndex:0];
}
@end
