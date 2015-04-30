//
//  SignDetailHeader.h
//  onestong
//
//  Created by 李健 on 14-7-10.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignDetailHeader : UIView
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

+ (SignDetailHeader *)loadFromNib;
@end
