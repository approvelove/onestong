//
//  UsersModel.m
//  onestong
//
//  Created by 王亮 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "UsersModel.h"

@implementation UsersModel
@synthesize companyDepartment, companyName,companyPosition,creator,department,deviceId,email,password,phone,remark,sex,token,updateTime,updator,userId,username,validSign,resetPassword,needSignIn,chartAuth,manageDepartmentsAuth,manageSubDepartmentsAuth;


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.companyDepartment forKey:@"companyDepartment"];
    [encoder encodeObject:self.companyName forKey:@"companyName"];
    [encoder encodeObject:self.companyPosition forKey:@"companyPosition"];
    [encoder encodeObject:self.creator forKey:@"creator"];
    [encoder encodeObject:self.department forKey:@"department"];
    [encoder encodeObject:self.deviceId forKey:@"deviceId"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.remark forKey:@"remark"];
    [encoder encodeObject:self.sex forKey:@"sex"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.updateTime forKey:@"updateTime"];
    [encoder encodeObject:self.updator forKey:@"updator"];
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.validSign forKey:@"validSign"];
    [encoder encodeObject:self.resetPassword forKey:@"resetPassword"];
    [encoder encodeObject:self.needSignIn forKey:@"needSignIn"];
    [encoder encodeObject:self.manageDepartmentsAuth forKey:@"manageDepartmentsAuth"];
    [encoder encodeObject:self.manageSubDepartmentsAuth forKey:@"manageSubDepartmentsAuth"];
    [encoder encodeObject:self.chartAuth forKey:@"chartAuth"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        self.companyDepartment = [decoder decodeObjectForKey:@"companyDepartment"];
        self.companyName = [decoder decodeObjectForKey:@"companyName"];
        self.companyPosition = [decoder decodeObjectForKey:@"companyPosition"];
        self.creator = [decoder decodeObjectForKey:@"creator"];
        self.department = [decoder decodeObjectForKey:@"department"];
        self.deviceId = [decoder decodeObjectForKey:@"deviceId"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.remark = [decoder decodeObjectForKey:@"remark"];
        self.sex = [decoder decodeObjectForKey:@"sex"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.updateTime = [decoder decodeObjectForKey:@"updateTime"];
        self.updator = [decoder decodeObjectForKey:@"updator"];
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.validSign = [decoder decodeObjectForKey:@"validSign"];
        self.resetPassword = [decoder decodeObjectForKey:@"resetPassword"];
        self.needSignIn = [decoder decodeObjectForKey:@"needSignIn"];
        self.manageSubDepartmentsAuth = [decoder decodeObjectForKey:@"manageSubDepartmentsAuth"];
        self.manageDepartmentsAuth = [decoder decodeObjectForKey:@"manageDepartmentsAuth"];
        self.chartAuth = [decoder decodeObjectForKey:@"chartAuth"];
    }
    return  self;
}

- (id)init
{
    self = [super init];
    if (self) {
        if (!self.department) {
            self.department = [[KeyValueModel alloc]init];
        }
    }
    return self;
}

-(id)initWithEmail:(NSString *)em andPassword:(NSString *)pwd
{
    self = [super init];
    if (self) {
        self->email = em;
        self->password = pwd;
    }
    return self;
}

-(NSString *)toJsonString
{
    return nil;
}

-(UsersModel *)fromDictionary: (NSDictionary *)obj
{
    if (!obj||![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self.userId = obj[@"id"];
    self.deviceId = obj[@"de"];
    self.password = obj[@"pa"];
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
    self.token = obj[@"to"];
    self.creator = obj[@"cr"];
    self.updateTime = obj[@"ut"];
    self.updator = obj[@"up"];
    self.validSign = obj[@"va"];
    self.remark = obj[@"re"];
    self.chartAuth = obj[@"ca"];
    self.manageDepartmentsAuth = obj[@"da"];
    self.manageSubDepartmentsAuth = obj[@"sa"];
    self.needSignIn = obj[@"ns"];
    if (obj[@"dp"]) {
        if (!self.department) {
            self.department = [[KeyValueModel alloc]init];
        }
        [self.department fromDictionary:obj[@"dp"]];
    }
    return self;
}
@end
