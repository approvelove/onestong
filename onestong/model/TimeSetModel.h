//
//  TimeSetModel.h
//  onestong
//
//  Created by 李健 on 14-6-5.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeSetModel : NSObject

@property (nonatomic, strong) NSString *timeId; // ID 无为空
@property (nonatomic, strong) NSString *startTime; //开始上班时间
@property (nonatomic, strong) NSString *endTime; //下班时间
@property (nonatomic, strong) NSString *creator; //cr创建时间
@property (nonatomic, strong) NSString *updateTime; //更新时间 ut
@property (nonatomic, strong) NSString *updator; //更新者 up
@property (nonatomic, strong) NSString *vaild; //有效标识 va
@property (nonatomic, strong) NSString *remark; //备注re

-(TimeSetModel *)fromDictionary: (NSDictionary *)obj;
@end
