//
//  UsersModel.h
//  onestong
//
//  Created by 王亮 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyValueModel.h"

@interface UsersModel : NSObject<NSCoding>

@property (copy, nonatomic) NSString *userId;//编号 id
@property (copy, nonatomic) NSString *deviceId;//设备编号 de
@property (copy, nonatomic) NSString *password;//密码 pa
@property (copy, nonatomic) NSString *resetPassword;//密码 pa
@property (copy, nonatomic) NSString *companyName;//公司名称 co.na
@property (copy, nonatomic) NSString *companyDepartment;//公司部门 co.de
@property (copy, nonatomic) NSString *companyPosition;//公司职位 co.po
@property (copy, nonatomic) NSString *username;//姓名 us
@property (copy, nonatomic) NSString *sex;//性别 se
@property (copy, nonatomic) NSString *phone;//电话 ph
@property (copy, nonatomic) NSString *email;//邮箱 em
@property (copy, nonatomic) NSString *token;//token to
@property (copy, nonatomic) NSString *creator;//创建者 cr
@property (copy, nonatomic) NSString *updateTime;//更新时间 ut
@property (copy, nonatomic) NSString *updator;//更新者 up
@property (copy, nonatomic) NSString *validSign;//有效标识 va 0:已激活 va:未激活
@property (copy, nonatomic) NSString *remark;//备注 re
@property (strong, nonatomic) KeyValueModel *department;//部门 dp.ud, dp.na
@property (nonatomic, strong) NSNumber *needSignIn; //是否需要签到 默认为0  ns
@property (nonatomic, strong) NSString *chartAuth; //是否有查看报表权限 默认为0 ca
@property (nonatomic, strong) NSString *manageDepartmentsAuth; // 是否有管理部门权限 默认为0 da
@property (nonatomic, strong) NSString *manageSubDepartmentsAuth; //是否有管理子部门权限 默认为0 sa

-(NSString *) toJsonString;
-(UsersModel *)fromDictionary: (NSDictionary *)obj;

-(id)initWithEmail:(NSString *)em andPassword:(NSString *)pwd;
@end
