//
//  EventModel.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeyValueModel.h"
#import "PlanAndActualModel.h"
#import "ResourceInfoModel.h"
#import "EventItemModel.h"
#import "RemarkModel.h"

@interface EventModel : NSObject
@property(copy, nonatomic)NSString *eventId; //id
@property(copy, nonatomic)NSString *eventName; //na 事件名称
@property(strong, nonatomic)KeyValueModel *eventType; //ty 事件类型
@property(strong, nonatomic)KeyValueModel *publisher; //pu 发布人
@property(strong, nonatomic)KeyValueModel *owner; //ow 所有者
@property(nonatomic)long long createTime; //ct 创建时间
@property(copy, nonatomic)NSString *creator; //cr 创建者
@property(nonatomic)long long updateTime; //ut 更新时间
@property(copy, nonatomic)NSString *updator; //up 更新者
@property (copy, nonatomic) NSString *validSign;//有效标识 va
@property (copy, nonatomic) NSString *remark;//备注 re
@property (strong , nonatomic) RemarkModel *remarkModel;//备注的图片
@property(nonatomic)int status; //st 状态
@property(strong, nonatomic)PlanAndActualModel *plan;//计划"pl":{"bt":"","ba":"","et":"","ea":""}
@property(strong, nonatomic)PlanAndActualModel *actual;//实际"ac":{"bt":"","ba":"","et":"","ea":""}
@property(strong, nonatomic)ResourceInfoModel *signIn;//签到“si”:{“ad”:””,”ti”:””,”ur”:””,”lo”:””,”la”:””,”lc”:””,”co":""}
@property(strong, nonatomic)ResourceInfoModel *signOut;//签退“so”:{“ad”:””,”ti”:””,”ur”:””,”lo”:””,”la”:””,”lc”:””,”co":""}
@property(strong, nonatomic)EventItemModel *eventItem;//事项 it
-(NSString *) toJson;
-(EventModel *)fromDictionary: (NSDictionary *)obj;

-(id)init;
@end


