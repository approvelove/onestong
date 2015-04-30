//
//  CDPlanAndActualDAO.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDPlanAndActual,PlanAndActualModel;

@interface CDPlanAndActualDAO : NSObject
+ (BOOL)save:(PlanAndActualModel *)model;
+ (CDPlanAndActual *)findById:(NSString *)eventId isPlan:(BOOL)isPlan;
+ (BOOL)clearData;
+ (BOOL)deleteById:(NSString *)eventId isPlan:(BOOL)isPlan;

+ (BOOL)update:(PlanAndActualModel *)model isPlan:(BOOL)isPlan;
@end
