//
//  CDResourceInfo.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDResourceInfo.h"
#import "ResourceInfoModel.h"

@implementation CDResourceInfo

@dynamic createTime;
@dynamic pictureName;
@dynamic longitude;
@dynamic latitude;
@dynamic location;
@dynamic content;
@dynamic eventId;
@dynamic isSignIn;

- (CDResourceInfo *)fromResourceinfoModel:(ResourceInfoModel *)model
{
    if (!model) {
        return nil;
    }
    self.createTime = @(model.createTime);
    self.pictureName = model.pictureUrl;
    self.longitude = @(model.longitude);
    self.latitude = @(model.latitude);
    self.location = model.location;
    self.content = model.content;
    self.eventId = model.eventId;
    self.isSignIn = @(model.isSignIn);
    return self;
}

- (ResourceInfoModel *)toResourceInfoModel
{
    ResourceInfoModel *model = [[ResourceInfoModel alloc] init];
    model.createTime = [self.createTime longLongValue];
    model.pictureUrl = self.pictureName;
    model.longitude = [self.longitude doubleValue];
    model.latitude = [self.latitude doubleValue];
    model.location = self.location;
    model.content = self.content;
    model.eventId = self.eventId;
    model.isSignIn = [self.isSignIn boolValue];
    return model;
}
@end
