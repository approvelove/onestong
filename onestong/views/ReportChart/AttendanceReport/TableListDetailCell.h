//
//  TableListDetailCell.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableListDetailCell : UITableViewCell

@property (nonatomic, weak)IBOutlet UILabel *dateLabel;
@property (nonatomic, weak)IBOutlet UILabel *lateLabe;
@property (nonatomic, weak)IBOutlet UILabel *earlyOutLabel;
@property (nonatomic, weak)IBOutlet UILabel *absenteeismLabel;
@property (nonatomic, weak)IBOutlet UIImageView *noSignOutImageView;

+ (TableListDetailCell *)loadFromNib;
@end
