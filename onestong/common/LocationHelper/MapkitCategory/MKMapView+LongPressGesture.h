//
//  MKMapView+TapGesture.h
//  MyTest
//
//  Created by 李健 on 14-3-5.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"

#define NOTIFICATION_SNAP_MAPIMAGE_OVER @"snap map image over"

@interface MKMapView (LongPressGesture)

/**
 *	@brief	添加一个长按手势
 *
 *	@return	nil
 */
- (void)addLongPressGesture;

/**
 *	@brief	大头针的单例
 *
 *	@return	返回大头针
 */
+ (MKPointAnnotation *)sharedPointAnnitation;

/**
 *	@brief	设置alertView的代理
 *
 *	@param 	delegate 	代理
 *
 *	@return	nil
 */
- (void)setAlertViewDelegate:(id)delegate;

/**
 *	@brief	设置大头针的标题
 *
 *	@param 	title 	标题
 *
 *	@return	nil
 */
- (void)showPointAnnotationWithTitle:(NSString *)title;

/**
 *	@brief	截图
 *
 *	@return	返回截的的图片
 */
- (void)getMapSnapShot;

@end
