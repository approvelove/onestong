//
//  LocationHelper.h
//  MyTest
//
//  Created by 李健 on 14-3-4.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_LOCATION @"location"
#define NOTIFICATION_LOCATION_ERROR @"location error"


@interface LocationHelper : NSObject
- (void)initGPSLocation;
- (void)startLocation;
@end
