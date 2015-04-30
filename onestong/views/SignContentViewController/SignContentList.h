//
//  SignContentList.h
//  onestong
//
//  Created by 李健 on 14-7-9.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignContentListDelegate;
@interface SignContentList : UIView

//@property (nonatomic, weak) IBOutlet UITableView *tableListView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *selectString;
@property (nonatomic, weak) id<SignContentListDelegate>delegate;

+ (SignContentList *)loadFromNib;
@end

@protocol SignContentListDelegate <NSObject>

- (void)signContentListSelectedTitle:(NSString *)title;

@end