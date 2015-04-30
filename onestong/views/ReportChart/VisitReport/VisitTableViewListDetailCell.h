//
//  VisitTableViewListDetailCell.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitTableViewListDetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *visitLabel;
@property (nonatomic, weak) IBOutlet UILabel *signInLabel;
@property (nonatomic, weak) IBOutlet UILabel *signOutLabel;


+ (VisitTableViewListDetailCell *)loadFromNib;
@end
