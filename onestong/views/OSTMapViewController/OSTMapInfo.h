//
//  OSTMapInfo.h
//  Transaction
//
//  Created by 李健 on 14-4-2.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface OSTMapInfo : NSObject
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) MKPinAnnotationView *pinAnnotation;
@end
