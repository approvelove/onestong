//
//  CDUser.m
//  onestong
//
//  Created by 李健 on 14-7-4.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDUser.h"
#import "UsersModel.h"

@implementation CDUser

@dynamic chartAuth;
@dynamic companyDepartment;
@dynamic companyName;
@dynamic companyPosition;
@dynamic departmentId;
@dynamic departmentName;
@dynamic deviceId;
@dynamic email;
@dynamic manageDepartmentAuth;
@dynamic manageSubDepartmentsAuth;
@dynamic needSignIn;
@dynamic phone;
@dynamic remark;
@dynamic sex;
@dynamic userId;
@dynamic username;
@dynamic validSign;
@dynamic ca;
@dynamic da;
@dynamic sa;

- (UsersModel *)toUsersModel
{
    UsersModel *model = [[UsersModel alloc] init];
    model.chartAuth = self.ca;
    model.companyDepartment = self.companyDepartment;
    model.companyName = self.companyName;
    model.companyPosition = self.companyPosition;
    model.department.modelId = self.departmentId;
    model.department.modelName = self.departmentName;
    model.deviceId = self.deviceId;
    model.email = self.email;
    model.manageDepartmentsAuth = self.da;
    model.manageSubDepartmentsAuth = self.sa;
    model.needSignIn = self.needSignIn;
    model.phone = self.phone;
    model.remark = self.remark;
    model.sex = self.sex;
    model.userId = self.userId;
    model.username = self.username;
    model.validSign = self.validSign;
    return model;
}

-(CDUser *)fromDictionary: (NSDictionary *)obj
{
    if (!obj) {
        return nil;
    }
    self.userId = obj[@"id"];
    self.deviceId = obj[@"de"];
    if (obj[@"co"]) {
        NSString * strco = obj[@"co"];
        NSError *error;
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:[strco dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        self.companyDepartment = dic[@"de"];
        self.companyName = dic[@"na"];
        self.companyPosition = dic[@"po"];
    }
    self.username = obj[@"us"];
    self.sex = obj[@"se"];
    self.phone = obj[@"ph"];
    self.email = obj[@"em"];
    self.validSign = obj[@"va"];
    self.remark = obj[@"re"];
    self.ca = obj[@"ca"];
    self.da = obj[@"da"];
    self.sa = obj[@"sa"];
    self.needSignIn = obj[@"ns"];
    if (obj[@"dp"]) {
        if (obj[@"dp"][@"ud"]) {
            self.departmentId = obj[@"dp"][@"ud"];
        }
        if (obj[@"dp"][@"na"]) {
            self.departmentName = obj[@"dp"][@"na"];
        }
    }
    return self;
}
@end
