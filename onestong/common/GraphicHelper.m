//
//  GraphicHelper.m
//  onestong
//
//  Created by 王亮 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "GraphicHelper.h"

@implementation GraphicHelper
    
+(void)convertRectangleToCircular:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.width / 2;
}

+(void)convertRectangleToCircular:(UIView *)view withBorderColor:(UIColor *)color andBorderWidth:(float)width
{
    [GraphicHelper convertRectangleToCircular:view];
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = width;
}

+(void)convertRectangleToEllipses:(UIView *)view withBorderColor:(UIColor *)color andBorderWidth:(float)width andRadius:(float)radius
{
    view.layer.cornerRadius = radius;
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = width;
}

+ (UIImage *)convertColorToImage:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}
@end
