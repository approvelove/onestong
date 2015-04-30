//
//  CDDepartmentDAO.h
//  onestong
//
//  Created by 王亮 on 14-5-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDDepartment;

@interface CDDepartmentDAO : NSObject
-(BOOL)save:(NSDictionary *)deptDic;
-(BOOL)update:(NSDictionary *)deptDic;
-(NSArray *)findAll;
-(CDDepartment *)findById:(NSString *)deptId;
-(NSArray *)findByParentId:(NSString *)parentId;
-(BOOL)clearData;
-(BOOL)deleteById:(NSString *)deptId;
- (NSArray *)findSubDepartmentById:(NSString *)deptId;

- (NSArray *)findByOwnerEmail:(NSString *)ownerEmail;
@end
