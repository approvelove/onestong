//
//  TableListDetailHeader.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "TableListDetailHeader.h"

@implementation TableListDetailHeader
@synthesize dateItem,lateItem,earlyOutItem,absenteeismItem,noSignOutItem,mainToolBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (TableListDetailHeader *)loadFromNib
{
    if (CURRENT_VERSION<7) {
        return [[[NSBundle mainBundle] loadNibNamed:@"TableListDetailHeader" owner:nil options:nil] objectAtIndex:1];
    }
    else
    {
        return [[[NSBundle mainBundle] loadNibNamed:@"TableListDetailHeader" owner:nil options:nil] objectAtIndex:0];
    }
}
@end
