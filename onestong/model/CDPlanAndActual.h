//
//  CDPlanAndActual.h
//  onestong
//
//  Created by 李健 on 14-8-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class PlanAndActualModel;

@interface CDPlanAndActual : NSManagedObject

@property (nonatomic, retain) NSString * beginAddress;
@property (nonatomic, retain) NSNumber * beginTime;
@property (nonatomic, retain) NSString * endAddress;
@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSNumber * isPlan;

- (CDPlanAndActual *)fromPlanAndActualModel:(PlanAndActualModel *)model;
- (PlanAndActualModel *)toPlanAndActualModel;
@end
