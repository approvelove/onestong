//
//  CDUser.h
//  onestong
//
//  Created by 李健 on 14-7-4.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class UsersModel;

@interface CDUser : NSManagedObject

@property (nonatomic, retain) NSNumber * chartAuth;
@property (nonatomic, retain) NSString * companyDepartment;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * companyPosition;
@property (nonatomic, retain) NSString * departmentId;
@property (nonatomic, retain) NSString * departmentName;
@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * manageDepartmentAuth;
@property (nonatomic, retain) NSNumber * manageSubDepartmentsAuth;
@property (nonatomic, retain) NSNumber * needSignIn;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * validSign;
@property (nonatomic, retain) NSString * ca;
@property (nonatomic, retain) NSString * da;
@property (nonatomic, retain) NSString * sa;
-(CDUser *)fromDictionary: (NSDictionary *)obj;
- (UsersModel *)toUsersModel;
@end
