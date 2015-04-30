//
//  DAContextMenuTableViewController.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "BaseViewController.h"
#import "DAContextMenuCell.h"

@interface DAContextMenuTableViewController : BaseViewController <DAContextMenuCellDelegate>

@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;
@property (nonatomic, strong) UITableView *OSTTableView;

@end
