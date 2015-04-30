//
//  SignDetailHeader.m
//  onestong
//
//  Created by 李健 on 14-7-10.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SignDetailHeader.h"

@implementation SignDetailHeader
@synthesize timeLabel;

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

+ (SignDetailHeader *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"SignDetailHeader" owner:nil options:nil] objectAtIndex:0];
}
@end
