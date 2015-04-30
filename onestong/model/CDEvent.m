//
//  CDEvent.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDEvent.h"
#import "CDEventItem.h"
#import "CDPlanAndActual.h"
#import "CDResourceInfo.h"
#import "EventModel.h"
#import "AppDelegate.h"
#import "CDPlanAndActualDAO.h"
#import "CDEventItemDAO.h"
#import "CDResourceInfoDAO.h"
#import "CDImageSource.h"
#import "CDImageSourceDAO.h"

@implementation CDEvent

@dynamic createTime;
@dynamic creator;
@dynamic eventId;
@dynamic eventName;
@dynamic remark;
@dynamic remarkImgAry;
@dynamic status;
@dynamic updateTime;
@dynamic updator;
@dynamic validSign;
@dynamic eventTypeId;
@dynamic eventTypeName;
@dynamic ownerId;
@dynamic ownerName;
@dynamic publisherId;
@dynamic publisherName;
@dynamic actual;
@dynamic eventItem;
@dynamic plan;
@dynamic signIn;
@dynamic signOut;

- (CDEvent *)fromEventModel:(EventModel *)model
{
    if (!model) {
        return nil;
    }
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    self.eventId = model.eventId;
    self.eventName = model.eventName;
    self.createTime = @(model.createTime);
    self.creator = model.creator;
    self.updateTime = @(model.updateTime);
    self.updator = model.updator;
    self.validSign = model.validSign;
    self.remark = model.remark;
    
    self.remarkImgAry = [self aryToSet:model.remarkModel.imageSource];
    self.status = @(model.status);
    
    self.eventTypeId = model.eventType.modelId;
    self.eventTypeName = model.eventType.modelName;
    
    self.publisherId = model.publisher.modelId;
    self.publisherName = model.publisher.modelName;
    
    self.ownerId = model.owner.modelId;
    self.ownerName = model.owner.modelName;

    CDPlanAndActual * planInfo = [CDPlanAndActualDAO findById:model.eventId isPlan:YES];
    if (!planInfo) {
        planInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    }
    model.plan.eventId = model.eventId;
    model.plan.isPlan = YES;
    [planInfo fromPlanAndActualModel:model.plan];
    self.plan = planInfo;
    
    CDPlanAndActual * actualInfo = [CDPlanAndActualDAO findById:model.eventId isPlan:NO];
    if (!actualInfo) {
        actualInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    }
    model.actual.eventId = model.eventId;
    model.actual.isPlan = NO;
    [actualInfo fromPlanAndActualModel:model.actual];
    self.actual = actualInfo;
    
    CDEventItem *itemInfo = [CDEventItemDAO findById:model.eventId];
    if (!itemInfo) {
        itemInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDEventItem" inManagedObjectContext:context];
    }
    model.eventItem.eventId = model.eventId;
    [itemInfo fromEventItemModel:model.eventItem];
    self.eventItem = itemInfo;
    
    CDResourceInfo *signInInfo = [CDResourceInfoDAO findById:model.eventId isSignIn:YES];
    if (!signInInfo) {
        signInInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDResourceInfo" inManagedObjectContext:context];
    }
    model.signIn.eventId = model.eventId;
    model.signIn.isSignIn = YES;
    [signInInfo fromResourceinfoModel:model.signIn];
    self.signIn = signInInfo;
    
    CDResourceInfo *signOutInfo = [CDResourceInfoDAO findById:model.eventId isSignIn:NO];
    if (!signOutInfo) {
        signOutInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDResourceInfo" inManagedObjectContext:context];
    }
    model.signOut.eventId = model.eventId;
    model.signOut.isSignIn = NO;
    [signOutInfo fromResourceinfoModel:model.signOut];
    self.signOut = signOutInfo;
    
    return self;
}


- (EventModel *)toEventModel
{
    EventModel *model = [[EventModel alloc] init];
    model.eventId = self.eventId;
    model.eventName = self.eventName;
    
    model.eventType = [[KeyValueModel alloc] init];
    model.eventType.modelId = self.eventTypeId;
    model.eventType.modelName = self.eventTypeName;
    
    model.publisher = [[KeyValueModel alloc] init];
    model.publisher.modelName = self.publisherName;
    model.publisher.modelId = self.publisherId;
    
    model.owner = [[KeyValueModel alloc] init];
    model.owner.modelId = self.ownerId;
    model.owner.modelName = self.ownerName;
    model.createTime = [self.createTime longLongValue];
    model.creator = self.creator;
    model.updateTime = [self.updateTime longLongValue];
    model.updator = self.updator;
    model.validSign = self.validSign;
    model.remark = self.remark;
    
    model.remarkModel = [[RemarkModel alloc] init];
    model.remarkModel.imageSource = [self unWarppenImageSourceAry:self.remarkImgAry];//此处要修改
    
    model.status = [self.status intValue];
    model.plan = [self.plan toPlanAndActualModel];
    model.actual = [self.actual toPlanAndActualModel];
    model.signIn = [self.signIn toResourceInfoModel];
    model.signOut = [self.signOut toResourceInfoModel];
    model.eventItem = [self.eventItem toEventItemModel];
    return model;
}
#pragma mark - helper
- (NSArray *)unWarppenImageSourceAry:(NSSet *)aSet
{
    NSMutableArray *temp = [@[] mutableCopy];
    [aSet enumerateObjectsUsingBlock:^(CDImageSource *obj, BOOL *stop) {
        [temp addObject:obj.url];
    }];
    return temp;
}

- (NSSet *)aryToSet:(NSArray *)ary
{
    if (!ary || ary.count ==0) {
        return nil;
    }
    NSMutableSet *set = [NSMutableSet set];
    for (int i=0; i<[ary count]; i++) {
        CDImageSource *source = [CDImageSourceDAO findByName:ary[i]];
        if (!source) {
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext * context = [delegate managedObjectContext];
            source = [NSEntityDescription insertNewObjectForEntityForName:@"CDImageSource" inManagedObjectContext:context];
        }
        source.url = ary[i];
        [set addObject:source];
    }
    return set;
}

@end
