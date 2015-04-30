//
//  GraphicHelper.h
//  onestong
//
//  Created by 王亮 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphicHelper : NSObject
+(void)convertRectangleToCircular:(UIView *)view;
+(void)convertRectangleToCircular:(UIView *)view withBorderColor:(UIColor *)color andBorderWidth:(float)width;
+(void)convertRectangleToEllipses:(UIView *)view withBorderColor:(UIColor *)color andBorderWidth:(float)width andRadius:(float)radius;
+ (UIImage *)convertColorToImage:(UIColor *)color;
@end
