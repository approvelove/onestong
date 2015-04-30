//
//  VisitTableListCell.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "VisitTableListCell.h"

@implementation VisitTableListCell
@synthesize nameLabel,visitLabel,userId,signInLabel,signOutLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (VisitTableListCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"VisitTableListCell" owner:nil options:nil] objectAtIndex:0];
}
@end
