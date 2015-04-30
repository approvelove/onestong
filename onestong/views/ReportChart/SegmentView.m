//
//  SegmentView.m
//  onestong
//
//  Created by 李健 on 14-6-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SegmentView.h"
#import "GraphicHelper.h"

@interface SegmentView ()
{
}
@end

@implementation SegmentView
@synthesize shadowView,todayButton,segmentBar,yesterdayButton,currentWeekButton,onWindow,lastWeekButton,currentMonthButton,lastMonthButton,otherDateButton;
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

- (void)changeButtonColorWhenClick:(UIButton *)sender
{
    for (UIButton *temp in [self.segmentBar subviews]) {
        if ([temp isMemberOfClass:[UIButton class]]) {
            [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
}

- (void)changeButtonColorWithTimeString:(NSString *)str
{
    for (UIButton *temp in [self.segmentBar subviews]) {
        if ([temp isMemberOfClass:[UIButton class]]) {
            NSLog(@"timeStr = %@",temp.titleLabel.text);
            NSString *descriptionStr = [temp.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([descriptionStr isEqualToString:str]) {
                [temp setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
            else
            {
                [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                if (str.length>5) {
                    [self.otherDateButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)initializedSegmentView
{
    [GraphicHelper convertRectangleToEllipses:self.segmentBar withBorderColor:rgbaColor(215, 215, 215, 1.f) andBorderWidth:0.5f andRadius:2.f];
}

- (void)swipe:(UIGestureRecognizer *)ges
{
    NSLog(@"swipe");
}

- (void)tap:(UIGestureRecognizer *)ges
{
    NSLog(@"tap");
}


+ (SegmentView *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"SegmentView" owner:nil options:nil] objectAtIndex:0];
}

@end
