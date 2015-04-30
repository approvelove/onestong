//
//  VisitTabelListHeader.h
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitTabelListHeader : UIView

@property (nonatomic, weak)IBOutlet UISearchBar *mainSearchBar;
@property (nonatomic, weak)IBOutlet UIBarButtonItem *visitNameItem;
@property (nonatomic, weak)IBOutlet UIBarButtonItem *visitVisitItem;
@property (nonatomic, weak)IBOutlet UIBarButtonItem *visitSignInItem;
@property (nonatomic, weak)IBOutlet UIBarButtonItem *visitSignOutItem;
@property (nonatomic, weak)IBOutlet UIToolbar *mainToolBar;

+ (VisitTabelListHeader *)loadFromNib;
@end
