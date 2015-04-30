//
//  CDEventDAO.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDEventDAO.h"
#import "AppDelegate.h"
#import "CDEvent.h"
#import "EventModel.h"
#import "TimeHelper.h"

@implementation CDEventDAO
+ (BOOL)save:(EventModel *)model
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    CDEvent * info = [NSEntityDescription insertNewObjectForEntityForName:@"CDEvent" inManagedObjectContext:context];
    [info fromEventModel:model];
    NSError * error;
    if ([context save:&error]) {
        NSLog(@"save users success");
        return YES;
    }else{
        NSLog(@"save users fail");
        return NO;
    }
}

+ (CDEvent *)findById:(NSString *)eventId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDEvent" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventId = %@", eventId];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    if (resultArr == nil || resultArr.count == 0) {
        return nil;
    }else{
        return resultArr[0];
    }
}

+ (NSDictionary *)findByOwinerId:(NSString *)ownerId andDateAry:(NSArray *)dateAry andSearchType:(FindType)type
{
    NSMutableDictionary *temp = [@{} mutableCopy];
    for (int i = 0; i<dateAry.count; i++) {
        NSArray *search = [CDEventDAO findByOwinerId:ownerId andDateStr:dateAry[i] andSearchType:type];
        if (search) {
            NSMutableArray *mutAry = [@[] mutableCopy];
            [search enumerateObjectsUsingBlock:^(CDEvent *obj, NSUInteger idx, BOOL *stop) {
                EventModel *tempModel = [obj toEventModel];
                [mutAry addObject:tempModel];
            }];
            [temp setObject:mutAry forKey:dateAry[i]];
        }
    }
    return temp;
}

+ (NSArray *)findByOwinerId:(NSString *)ownerId andDateStr:(NSString *)dateStr andSearchType:(FindType)type
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSString *fromDate = [NSString stringWithFormat:@"%@ 00:00:00",dateStr];
    NSString *toDate = [NSString stringWithFormat:@"%@ 23:59:59",dateStr];
    
    NSDate *frD = [TimeHelper timeFromString:fromDate andFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *trD = [TimeHelper timeFromString:toDate andFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    long long fromNum = [TimeHelper convertDateToSecondTime:frD];
    long long toNum = [TimeHelper convertDateToSecondTime:trD];
    
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDEvent" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate * predicate;
    switch (type) {
        case FindType_All:
            {
                predicate = [NSPredicate predicateWithFormat:@"(ownerId = %@ AND (createTime >= %@) AND (createTime <= %@))", ownerId,@(fromNum),@(toNum)];
            }
            break;
        case FindType_Attendance:
            {
                predicate = [NSPredicate predicateWithFormat:@"(ownerId = %@ AND (createTime >= %@) AND (createTime <= %@) AND eventTypeId = %@)", ownerId,@(fromNum),@(toNum),@"1"];
            }
            break;
        case FindType_Visit:
            {
                predicate = [NSPredicate predicateWithFormat:@"(ownerId = %@ AND (createTime >= %@) AND (createTime <= %@) AND eventTypeId = %@)", ownerId,@(fromNum),@(toNum),@"2"];
            }
            break;
    }
    [request setPredicate: predicate];
    
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    NSArray *sortArray = [resultArr sortedArrayUsingComparator:^NSComparisonResult(CDEvent *obj1, CDEvent *obj2) {
        if ([obj1.createTime longLongValue]>[obj2.createTime longLongValue]) {
            return NSOrderedAscending;
        }
        else
            return NSOrderedDescending;
    }];
   return sortArray;
}

+ (BOOL)clearData
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDEvent" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    return YES;
}

+ (BOOL)deleteById:(NSString *)eventId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDEvent" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventId = %@", eventId];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    return YES;
}

+ (BOOL)update:(EventModel *)model
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDEvent" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventId = %@", model.eventId];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    if (resultArr && resultArr.count >0) {
        CDEvent * info = resultArr[0];
        [info fromEventModel:model];
        if ([context save:&error]) {
            NSLog(@"update departments success");
            return YES;
        }else{
            NSLog(@"update departments fail");
            return NO;
        }
    }else{
        return NO;
    }
}
@end
