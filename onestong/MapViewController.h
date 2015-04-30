//
//  MapViewController.h
//  Transaction
//
//  Created by 李健 on 14-3-28.
//  Copyright (c) 2014年 李健. All rights reserved.
//

//CLLocation

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

@interface MapViewController : UIViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSArray *pointViewAry;
@end
