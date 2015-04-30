//
//  TableListDetailCell.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "TableListDetailCell.h"

@implementation TableListDetailCell
@synthesize dateLabel,lateLabe,earlyOutLabel,absenteeismLabel,noSignOutImageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (TableListDetailCell *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TableListDetailCell" owner:nil options:nil] objectAtIndex:0];
}
@end
