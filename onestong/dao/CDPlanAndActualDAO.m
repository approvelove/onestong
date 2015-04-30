//
//  CDPlanAndActualDAO.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDPlanAndActualDAO.h"
#import "AppDelegate.h"
#import "CDPlanAndActual.h"
#import "PlanAndActualModel.h"

@implementation CDPlanAndActualDAO

+ (BOOL)save:(PlanAndActualModel *)model
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    CDPlanAndActual * info = [NSEntityDescription insertNewObjectForEntityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    [info fromPlanAndActualModel:model];
    
    NSError * error;
    if ([context save:&error]) {
        NSLog(@"save users success");
        return YES;
    }else{
        NSLog(@"save users fail");
        return NO;
    }
}

+ (CDPlanAndActual *)findById:(NSString *)eventId isPlan:(BOOL)isPlan
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isPlan = %@)", eventId,@(isPlan)];
    
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

+ (BOOL)clearData
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    
    return YES;
}

+ (BOOL)deleteById:(NSString *)eventId isPlan:(BOOL)isPlan
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isPlan = %@)", eventId,@(isPlan)];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    return YES;
}

+ (BOOL)update:(PlanAndActualModel *)model isPlan:(BOOL)isPlan
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDPlanAndActual" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isPlan = %@)", model.eventId,@(isPlan)];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    if (resultArr && resultArr.count >0) {
        CDPlanAndActual * info = resultArr[0];
        [info fromPlanAndActualModel:model];
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
