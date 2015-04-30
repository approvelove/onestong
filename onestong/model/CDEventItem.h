//
//  CDEventItem.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class EventItemModel;

@interface CDEventItem : NSManagedObject

@property (nonatomic, retain) NSString * aimInfo;
@property (nonatomic, retain) NSSet * aimResource;
@property (nonatomic, retain) NSString * resultInfo;
@property (nonatomic, retain) NSSet * resultResource;
@property (nonatomic, retain) NSString *eventId;

- (CDEventItem *)fromEventItemModel:(EventItemModel *)model;
- (EventItemModel *)toEventItemModel;
@end
