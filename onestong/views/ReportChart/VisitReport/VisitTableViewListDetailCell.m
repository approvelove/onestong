//
//  VisitTableViewListDetailCell.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "VisitTableViewListDetailCell.h"

@implementation VisitTableViewListDetailCell
@synthesize timeLabel,visitLabel,signInLabel,signOutLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (VisitTableViewListDetailCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"VisitTableViewListDetailCell" owner:nil options:nil] objectAtIndex:0];
}
@end
