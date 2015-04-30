//
//  ImageShowViewController.h
//  onestong
//
//  Created by 李健 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"

static NSString *const IMAGESHOWVIEWCONTROLLER_DELETEIMAGE_NOTIFICATION = @"imageshowviewcontroller deleteimage notification";

@interface ImageShowViewController : BaseViewController

@property (strong, nonatomic) UIImage *screenimage;
@property (nonatomic) BOOL deletButtonHidden;

@end
