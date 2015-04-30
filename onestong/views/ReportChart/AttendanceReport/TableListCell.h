//
//  TableListCell.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lateLabel;
@property (nonatomic, weak) IBOutlet UILabel *earlyOutLabel;
@property (nonatomic, weak) IBOutlet UILabel *absenteeismLabel;
@property (nonatomic, weak) IBOutlet UILabel *noSignOutLabel;
@property (nonatomic, weak) IBOutlet UILabel *visitNumLabel;
@property (nonatomic, strong) NSString *userId;

+ (TableListCell *)loadFromNib;
@end
