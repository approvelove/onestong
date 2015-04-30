//
//  CDEventItem.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDEventItem.h"
#import "EventItemModel.h"
#import "AppDelegate.h"
#import "CDImageSourceDAO.h"
#import "CDImageSource.h"

@implementation CDEventItem

@dynamic aimInfo;
@dynamic aimResource;
@dynamic resultInfo;
@dynamic resultResource;
@dynamic eventId;

- (CDEventItem *)fromEventItemModel:(EventItemModel *)model
{
    if (!model) {
        return nil;
    }
    self.aimInfo = model.aimInfo;
    self.aimResource = [self aryToSet:model.aimResource];
    self.resultInfo = model.resultInfo;
    self.resultResource = [self aryToSet:model.resultResource];
    self.eventId = model.eventId;
    return self;
}

- (EventItemModel *)toEventItemModel
{
    EventItemModel *model = [[EventItemModel alloc] init];
    model.aimInfo = self.aimInfo;
    model.aimResource = [self unWarppenImageSourceAry:self.aimResource];
    model.resultInfo = self.resultInfo;
    model.resultResource = [self unWarppenImageSourceAry:self.resultResource];
    model.eventId = self.eventId;
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
