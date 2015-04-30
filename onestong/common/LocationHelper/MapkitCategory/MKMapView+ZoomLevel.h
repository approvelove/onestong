//
//  MKMapView+ZoomLevel.h
//  MyTest
//
//  Created by 李健 on 14-3-7.
//  Copyright (c) 2014年 李健. All rights reserved.
//

//iOS 地图缩放级别 20为最高级别，在该级别下显示的地图区域颗粒最细。最高级别为0，在该级别下显示的区域最大
#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

/**
 *	@brief	设置地图缩放级别
 *
 *	@param 	centerCoordinate 	设置地图的中心点
 *	@param 	zoomLevel 	缩放级别
 *	@param 	animated 	是否动画展示
 *
 *	@return	nil
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

/**
 *	@brief	将所有的大头针显示在地图上
 *
 *	@param 	pointAry 	要显示的大头针
 *
 *	@return	nil
 */
- (void)showAllPointPinOnMapWithPointArrary:(NSArray *)pointAry;

@end
