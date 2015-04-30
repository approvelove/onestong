//
//  SignDetailCell.h
//  onestong
//
//  Created by 李健 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSTButton.h"
@class EventModel;
@class OSTImageView;

@interface SignDetailCell : UITableViewCell

@property (weak,nonatomic) IBOutlet OSTImageView *mapImageView;
@property (weak, nonatomic) IBOutlet OSTButton *signOutButton;
@property (nonatomic,weak) UIView *ostContentView;
@property (nonatomic, weak) IBOutlet OSTButton *editButton;
@property (nonatomic, weak) IBOutlet OSTButton *writeSummaryButton;

- (void)initAttendanceNoSignOutCellWithEventModel:(EventModel *)eventModel;
- (void)initAttendanceHasSignOutCellWithEventModel:(EventModel *)eventModel;
- (void)initVisitHasSignOutCellWithEventModel:(EventModel *)eventModel;
- (void)initVisitnoSignOutCellWithEventModel:(EventModel *)eventModel;

- (void)remarkDescription:(NSString *)descriptionStr;
- (void)signInDescription:(NSString *)descriptionStr;
- (void)signOutDescription:(NSString *)descriptionStr;
- (void)setSignInImageViewWithImageURLArray:(NSArray *)imageArray;
- (void)setSignOutImageViewWithImageURLArray:(NSArray *)imageArray;
- (void)setSignInDate:(NSDateComponents *)dateCompnents;
- (void)setSignOutDate:(NSDateComponents *)dateCompnents;
- (void)setImageToImageView:(UIImageView *)imageView withFilename:(NSString *)filename;

+ (SignDetailCell *)loadVisitEventNoSignOutFromNib;
+ (SignDetailCell *)loadVisitEventHasSignOutFromNib;
+ (SignDetailCell *)loadAttendanceEventNoSignOutFromNib;
+ (SignDetailCell *)loadAttendanceEventHasSignOutFromNib;
@end
