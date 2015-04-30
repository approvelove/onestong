//
//  TableListCell.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "TableListCell.h"

@implementation TableListCell
@synthesize nameLabel,lateLabel,earlyOutLabel,absenteeismLabel,visitNumLabel,noSignOutLabel,userId;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (TableListCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TableListCell" owner:nil options:nil] objectAtIndex:0];
}
@end
