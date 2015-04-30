//
//  TableHeader.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeader : UIView
@property (nonatomic ,weak) IBOutlet UISearchBar *mainSearchBar;

@property (nonatomic ,weak) IBOutlet UIBarButtonItem *nameItem;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *lateItem;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *earlyOutItem;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *absenteeismItem;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *noSignOutItem;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *visitItem;
@property (nonatomic ,weak) IBOutlet UIToolbar *mainToolBar;

+ (TableHeader *)loadFromNib;
@end
