//
//  CDUserDAO.m
//  onestong
//
//  Created by 王亮 on 14-5-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDUserDAO.h"
#import "AppDelegate.h"
#import "CDUser.h"
#import "CDDepartmentDAO.h"
#import "CDDepartment.h"

@implementation CDUserDAO
-(BOOL)save:(NSDictionary *)userDic
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    CDUser * user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
    [user fromDictionary:userDic];
  
    NSError * error;
    if ([context save:&error]) {
        NSLog(@"save users success");
        return YES;
    }else{
        NSLog(@"save users fail");
        return NO;
    }
}

-(NSArray *)findAll
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    return resultArr;
}

-(CDUser *)findById:(NSString *)userId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
  
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

-(CDUser *)findByEmail:(NSString *)email
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    
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


- (NSMutableArray *)findBySuperOwnerEmail:(NSString *)ownEmail
{
    NSArray *deptAry = [[[CDDepartmentDAO alloc] init] findByOwnerEmail:ownEmail];
    NSMutableArray *resultAry = [@[] mutableCopy];
    if (deptAry&&deptAry.count>0) {
        for (int i=0; i<[deptAry count]; i++) {
            CDDepartment *tempDept = deptAry[i];
            if (tempDept.deptId&&tempDept.deptId.length>0) {
                NSArray *userAry = [self findByDepartmentId:tempDept.deptId];
                [resultAry addObjectsFromArray:userAry];
            }
        }
    }
    return resultAry;
}

-(BOOL)update:(NSDictionary *)userDic
{
    if (![userDic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId = %@", userDic[@"id"]];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    if (resultArr && resultArr.count >0) {
        CDUser * us = resultArr[0];
        [us fromDictionary:userDic];
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

-(NSArray *)findByDepartmentId:(NSString *)deptId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"departmentId = %@", deptId];
    [request setEntity:entity];
    [request setPredicate: predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    return resultArr;
}

-(BOOL)clearData
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    
    return YES;
}

-(BOOL)deleteById:(NSString *)userId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    return YES;
}
@end
