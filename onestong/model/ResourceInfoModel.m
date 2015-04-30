//
//  ResourceInfoModel.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "ResourceInfoModel.h"

@implementation ResourceInfoModel
@synthesize content,latitude,location,longitude,pictureUrl,createTime,eventId,isSignIn;

-(ResourceInfoModel *)fromDictionary: (NSDictionary *)obj
{
    self.pictureUrl = obj[@"ur"];
    self.createTime = [obj[@"ti"] longLongValue];
    self.location = obj[@"lc"];
    self.latitude = [obj[@"la"] doubleValue];
    self.longitude = [obj[@"lo"]doubleValue];
    return self;
}
@end
