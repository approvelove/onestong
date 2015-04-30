//
//  SegmentView.h
//  onestong
//
//  Created by 李健 on 14-6-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentView : UIView
@property (nonatomic, weak) IBOutlet UIView *shadowView;
@property (nonatomic, weak) IBOutlet UIView *segmentBar;
@property (nonatomic, weak) IBOutlet UIButton *todayButton;
@property (nonatomic, weak) IBOutlet UIButton *yesterdayButton;
@property (nonatomic, weak) IBOutlet UIButton *currentWeekButton;
@property (nonatomic, weak) IBOutlet UIButton *lastWeekButton;
@property (nonatomic, weak) IBOutlet UIButton *currentMonthButton;
@property (nonatomic, weak) IBOutlet UIButton *lastMonthButton;
@property (nonatomic, weak) IBOutlet UIButton *otherDateButton;

@property (nonatomic) BOOL  onWindow;

- (void)changeButtonColorWhenClick:(UIButton *)sender;
- (void)changeButtonColorWithTimeString:(NSString *)str;

- (void)initializedSegmentView;
+ (SegmentView *)loadFromNib;
@end
