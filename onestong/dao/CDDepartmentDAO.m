//
//  CDDepartmentDAO.m
//  onestong
//
//  Created by 王亮 on 14-5-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDDepartmentDAO.h"
#import "AppDelegate.h"
#import "CDDepartment.h"

@implementation CDDepartmentDAO
-(BOOL)save:(NSDictionary *)deptDic
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    CDDepartment * dept = [NSEntityDescription insertNewObjectForEntityForName:@"CDDepartment" inManagedObjectContext:context];
    [dept fromDictionary:deptDic];
    
    NSError * error;
    if ([context save:&error]) {
        NSLog(@"save departments success");
        return YES;
    }else{
        NSLog(@"save departments fail");
        return NO;
    }
}

-(BOOL)update:(NSDictionary *)deptDic
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"deptId = %@", deptDic[@"id"]];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    if (resultArr && resultArr.count >0) {
        CDDepartment * dept = resultArr[0];
        [dept fromDictionary:deptDic];
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

-(NSArray *)findAll
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    return resultArr;
}

- (NSArray *)findByOwnerEmail:(NSString *)ownerEmail
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"owneremail like[cd]%@", [NSString stringWithFormat:@"*,%@,*", ownerEmail]];
    
    //    排序
    //    NSSortDescriptor * sort = [[NSortDescriptor alloc] initWithKey:@"name"];
    //    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    return resultArr;
}

-(CDDepartment *)findById:(NSString *)deptId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"deptId = %@", deptId];
    
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

-(NSArray *)findByParentId:(NSString *)parentId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"parentId like[cd]%@", [NSString stringWithFormat:@"*,%@,*", parentId]];
    
    //    排序
    //    NSSortDescriptor * sort = [[NSortDescriptor alloc] initWithKey:@"name"];
    //    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    return resultArr;
}

- (NSArray *)findSubDepartmentById:(NSString *)deptId
{
    CDDepartment * dept = [self findById:deptId];
    NSString * parentName = dept.deptname;
    
    if (!dept.parentName && ![dept.parentName isEqualToString:@""]) {
        parentName = [NSString stringWithFormat:@"%@-%@", dept.parentName, dept.deptname];
    }
//    else
//    {
////        parentName = @"美承集团";
//    }
    
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"parentName like[cd]%@", [NSString stringWithFormat:@"*%@*", parentName]];
    
    //    排序
    //    NSSortDescriptor * sort = [[NSortDescriptor alloc] initWithKey:@"name"];
    //    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    //    [fetch setSortDescriptors: sortDescriptors];
    
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
  
    NSMutableArray * array = [resultArr mutableCopy];
    
    [array insertObject:dept atIndex:0];
    
    return array;
}

-(BOOL)clearData
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError * error;
    NSArray *resultArr = [context executeFetchRequest:request error:&error];
    [resultArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    
    return YES;
}

-(BOOL)deleteById:(NSString *)deptId
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc]init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"CDDepartment" inManagedObjectContext:context];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"deptId = %@", deptId];
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
