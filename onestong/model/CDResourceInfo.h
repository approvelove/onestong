//
//  CDResourceInfo.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ResourceInfoModel;
@interface CDResourceInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * createTime;
@property (nonatomic, retain) NSString * pictureName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString *eventId;
@property (nonatomic, retain) NSNumber *isSignIn;

- (CDResourceInfo *)fromResourceinfoModel:(ResourceInfoModel *)model;
- (ResourceInfoModel *)toResourceInfoModel;
@end
