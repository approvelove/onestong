//
//  VisitTabelListHeader.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "VisitTabelListHeader.h"

@implementation VisitTabelListHeader

@synthesize mainSearchBar,visitNameItem,visitSignInItem,visitSignOutItem,visitVisitItem,mainToolBar;
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

+ (VisitTabelListHeader *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"VisitTabelListHeader" owner:nil options:nil] objectAtIndex:0];
}
@end
