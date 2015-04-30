//
//  CDEvent.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEventItem, CDPlanAndActual, CDResourceInfo,EventModel;

@interface CDEvent : NSManagedObject

@property (nonatomic, retain) NSNumber * createTime;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSSet * remarkImgAry;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * updateTime;
@property (nonatomic, retain) NSString * updator;
@property (nonatomic, retain) NSString * validSign;
@property (nonatomic, retain) NSString * eventTypeId;
@property (nonatomic, retain) NSString * eventTypeName;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * publisherId;
@property (nonatomic, retain) NSString * publisherName;
@property (nonatomic, retain) CDPlanAndActual *actual;
@property (nonatomic, retain) CDEventItem *eventItem;
@property (nonatomic, retain) CDPlanAndActual *plan;
@property (nonatomic, retain) CDResourceInfo *signIn;
@property (nonatomic, retain) CDResourceInfo *signOut;

- (CDEvent *)fromEventModel:(EventModel *)model;
- (EventModel *)toEventModel;
@end
