//
//  OSTImageView.h
//  onestong
//
//  Created by 李健 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const OSTIMAGEVIEW_PICKIMAGE_NOTIFICATION = @"pick ostimage notification";
static NSString * const OSTIMAGEVIEW_SHOWIMAGE_NOTIFICATION = @"show ostimage on another controller";

@interface OSTImageView : UIImageView

@property (nonatomic, copy) NSArray *mapInfoAry;
@property (nonatomic) BOOL imageSetted;
/**
 *	@brief	查看大图 (在使用该方法时请确保您的视图刚刚初始化)
 *
 *	@param 	controller 	当前 imageview所在的视图控制器
 *
 *	@return	nil
 */
- (void)registTapGestureShowImage;

+(NSData*)compressImage:(UIImage*)image;
@end
