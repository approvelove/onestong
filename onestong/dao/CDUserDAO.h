//
//  CDUserDAO.h
//  onestong
//
//  Created by 王亮 on 14-5-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDUser;

@interface CDUserDAO : NSObject
-(BOOL)save:(NSDictionary *)userDic;
-(NSArray *)findAll;
-(CDUser *)findById:(NSString *)userId;
-(NSArray *)findByDepartmentId:(NSString *)deptId;
-(BOOL)clearData;
-(BOOL)deleteById:(NSString *)userId;
-(CDUser *)findByEmail:(NSString *)email;
-(BOOL)update:(NSDictionary *)userDic;
- (NSMutableArray *)findBySuperOwnerEmail:(NSString *)ownEmail;
@end
