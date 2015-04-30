//
//  EventItemModel.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventItemModel : NSObject
@property(copy, nonatomic)NSString *aimInfo; //ai 目标描述
@property(copy, nonatomic)NSArray *aimResource; //ar 目标资源
@property(copy, nonatomic)NSString *resultInfo; //ri 结果描述
@property(copy, nonatomic)NSArray *resultResource; //rr 结果资源
@property(copy, nonatomic)NSString *eventId;

-(EventItemModel *)fromDictionary: (NSDictionary *)obj;

@end
