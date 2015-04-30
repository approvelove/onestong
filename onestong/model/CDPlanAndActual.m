//
//  CDPlanAndActual.m
//  onestong
//
//  Created by 李健 on 14-8-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDPlanAndActual.h"
#import "PlanAndActualModel.h"

@implementation CDPlanAndActual

@dynamic beginAddress;
@dynamic beginTime;
@dynamic endAddress;
@dynamic endTime;
@dynamic eventId;
@dynamic isPlan;

- (CDPlanAndActual *)fromPlanAndActualModel:(PlanAndActualModel *)model
{
    if (!model) {
        return nil;
    }
    self.beginTime = @(model.beginTime);
    self.beginAddress = model.beginAddress;
    self.endTime = @(model.endTime);
    self.endAddress = model.endAddress;
    self.eventId = model.eventId;
    self.isPlan = @(model.isPlan);
    return self;
}

- (PlanAndActualModel *)toPlanAndActualModel
{
    PlanAndActualModel *model = [[PlanAndActualModel alloc] init];
    model.beginAddress = self.beginAddress;
    model.beginTime = [self.beginTime longLongValue];
    model.endAddress = self.endAddress;
    model.endTime = [self.endTime longLongValue];
    model.eventId = self.eventId;
    model.isPlan = [self.isPlan boolValue];
    return model;
}
@end
