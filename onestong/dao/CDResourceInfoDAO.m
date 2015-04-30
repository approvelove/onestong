//
//  CDResourceInfoDAO.m
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDResourceInfoDAO.h"
#import "AppDelegate.h"
#import "ResourceInfoModel.h"
#import "CDResourceInfo.h"

@implementation CDResourceInfoDAO

+ (BOOL)save:(ResourceInfoModel *)model
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    CDResourceInfo * info = [NSEntityDescription insertNewObjectForEntityForName:@"CDResourceInfo" inManagedObjectContext:context];
    [info fromResourceinfoModel:model];
    
    NSError * error;
    if ([context save:&error]) {
        NSLog(@"save users success");
        return YES;
    }else{
        NSLog(@"save users fail");
        return NO;
    }
}

+ (CDResourceInfo *)findById:(NSString *)eventId isSignIn:(BOOL)isSignIn
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDResourceInfo" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isSignIn = %@)", eventId,@(isSignIn)];
    
    //    排序
    //    NSSortDescriptor * sort = [[NSortDescriptor alloc] initWithKey:@"name"];
    //    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    //    [fetch setSortDescriptors: sortDescriptors];
    
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
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDResourceInfo" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    
    return YES;
}

+ (BOOL)deleteById:(NSString *)eventId isSignIn:(BOOL)isSignIn
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDResourceInfo" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isSignIn = %@)", eventId,@(isSignIn)];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    return YES;
}

+ (BOOL)update:(ResourceInfoModel *)model isSignIn:(BOOL)isSignIn
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDResourceInfo" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(eventId = %@ AND isSignIn = %@)", model.eventId,@(isSignIn)];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    if (resultArr && resultArr.count >0) {
        CDResourceInfo * info = resultArr[0];
        [info fromResourceinfoModel:model];
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
