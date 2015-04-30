//
//  VisitTableListCell.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitTableListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *visitLabel;
@property (nonatomic, weak) IBOutlet UILabel *signInLabel;
@property (nonatomic, weak) IBOutlet UILabel *signOutLabel;
@property (nonatomic, strong) NSString *userId;

+ (VisitTableListCell *)loadFromNib;
@end
