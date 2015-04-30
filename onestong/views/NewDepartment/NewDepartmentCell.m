//
//  NewDepartmentCell.m
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "NewDepartmentCell.h"
#import "GraphicHelper.h"

@implementation NewDepartmentCell
@synthesize titleLabel,vLine,selectionButton,user,department,bottomLine;
- (void)awakeFromNib
{
    // Initialization code
    [self setUp];
}

- (void)setUp
{
    [self.selectionButton setBackgroundImage:[GraphicHelper convertColorToImage:[UIColor grayColor]] forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (NewDepartmentCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"NewDepartmentCell" owner:nil options:nil] objectAtIndex:0];
}
@end
