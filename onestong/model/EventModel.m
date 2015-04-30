//
//  EventModel.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "EventModel.h"

@implementation EventModel
@synthesize actual,signOut,signIn,createTime,creator,eventId,eventName,eventType,eventItem,owner,plan,publisher,remark,status,updateTime,updator,validSign,remarkModel;

-(id)init
{
    self = [super init];
    if (self) {
        self.eventType = [[KeyValueModel alloc]init];
        self.publisher = [[KeyValueModel alloc]init];
        self.owner = [[KeyValueModel alloc]init];
        self.plan = [[PlanAndActualModel alloc]init];
        self.actual = [[PlanAndActualModel alloc]init];
        self.signIn = [[ResourceInfoModel alloc]init];
        self.signOut = [[ResourceInfoModel alloc]init];
        self.eventItem = [[EventItemModel alloc]init];
        self.remarkModel = [[RemarkModel alloc] init];
    }
    return self;
}

-(NSString *) toJson
{
    return nil;
}
-(EventModel *)fromDictionary: (NSDictionary *)obj
{
    self.eventId = obj[@"id"];
    self.creator = obj[@"cr"];
    self.validSign = obj[@"va"];
    self.updator = obj[@"up"];
    self.eventName = obj[@"na"];
    
    if (obj[@"st"]) {
        self.status = [obj[@"st"]intValue];
    }
    
    if (obj[@"ct"]) {
        self.createTime = [obj[@"ct"]longLongValue];
    }
    
    if (obj[@"ut"]) {
        self.updateTime = [obj[@"ut"]longLongValue];
    }
    
    if (obj[@"pl"]) {
        if (!self.plan) {
            self.plan = [[PlanAndActualModel alloc]init];
        }
        [self.plan fromDictionary:obj[@"pl"]];
    }
    
    if (obj[@"ac"]) {
        if (!self.actual) {
            self.actual = [[PlanAndActualModel alloc]init];
        }
        [self.actual fromDictionary:obj[@"ac"]];
    }
    
    if (obj[@"re"]) {
        self.remark = obj[@"re"];
    }
    
    if (obj[@"it"]){
        if (!self.eventItem) {
            self.eventItem = [[EventItemModel alloc]init];
        }
        [self.eventItem fromDictionary:obj[@"it"]];
    }
    
    if (obj[@"si"]) {
        if (!self.signIn) {
            self.signIn = [[ResourceInfoModel alloc]init];
        }
        [self.signIn fromDictionary:obj[@"si"]];
    }
    
    if (obj[@"so"]) {
        if (!self.signOut) {
            self.signOut = [[ResourceInfoModel alloc]init];
        }
        [self.signOut fromDictionary:obj[@"so"]];
    }
    
    if (obj[@"rp"]) {
        if (!self.remarkModel) {
            self.remarkModel = [[RemarkModel alloc]init];
        }
        [self.remarkModel fromArray:obj[@"rp"]];
    }
    
    if (obj[@"ow"]) {
        if (!self.owner) {
            self.owner = [[KeyValueModel alloc]init];
        }
        [self.owner fromDictionary:obj[@"ow"]];
    }
    
    if (obj[@"pu"]) {
        if (!self.publisher) {
            self.publisher = [[KeyValueModel alloc]init];
        }
        [self.publisher fromDictionary:obj[@"pu"]];
    }
    
    if (obj[@"ty"]) {
        if (!self.eventType) {
            self.eventType = [[KeyValueModel alloc]init];
        }
        [self.eventType fromDictionary:obj[@"ty"]];
    }
    
    return self;
}
@end