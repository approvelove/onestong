//
//  UIView+screenshot.m
//  onestong
//
//  Created by 李健 on 14-6-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "UIView+screenshot.h"

@implementation UIView (screenshot)

- (UIImage *)screenshot
{
	UIGraphicsBeginImageContext(self.bounds.size);
	[[UIColor clearColor] setFill];
	[[UIBezierPath bezierPathWithRect:self.bounds] fill];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[self.layer renderInContext:ctx];
	UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return anImage;
}

@end
