//
//  PlanAndActualModel.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlanAndActualModel : NSObject
@property(nonatomic)long long beginTime; //bt 开始时间
@property(copy, nonatomic)NSString *beginAddress; //ba 开始地址
@property(nonatomic)long long endTime; //et 开始时间
@property(copy, nonatomic)NSString *endAddress; //ea 开始地址
@property(copy, nonatomic)NSString *eventId; //
@property(nonatomic) BOOL isPlan;

-(PlanAndActualModel *)fromDictionary: (NSDictionary *)obj;
@end
