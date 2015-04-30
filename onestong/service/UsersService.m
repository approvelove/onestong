//
//  UsersService.m
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "UsersService.h"
#import "CommonHelper.h"
#import "UsersModel.h"
#import "CDUserDAO.h"

static NSString * const PERSONAL_MODIFY_USER_INFO = @"1";
static NSString * const ADMINISTRATOR_MODIFY_USER_INFO = @"2";

//static NSString *const EDITUSER_URL = @"users/%@/edit";

@interface UsersService ()
{
    NSDictionary *passwordCompatable;
}
@end

@implementation UsersService

#pragma mark -
#pragma mark  interface
-(void)login:(UsersModel *)user
{
    NSString *oldPassword = user.password;
    user.password = [CommonHelper md5:user.password];
    passwordCompatable = @{user.password:oldPassword};
    user.deviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSDictionary *dic = @{@"email":user.email, @"pwd":user.password, @"deviceId":user.deviceId};
    NSString *loginUrl = [NSString stringWithFormat:@"%@users/login", BASE_URL];
    [[AFHTTPRequestOperationManager manager]POST:loginUrl parameters:dic success:^(AFHTTPRequestOperation *operation, NSDictionary * responseObject) {
        [CommonHelper postNotification:LOGIN_COMPELETE_NOTIFICATION userInfo:[self packagingDictionaryWithDictionary:responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:LOGIN_COMPELETE_NOTIFICATION userInfo:nil];
    }];
}

-(void)resetPasswordWithUserId:(NSString *)userId
{
    NSString *resetPasswordURL = [NSString stringWithFormat:@"%@user/reset/%@",BASE_URL,[self getToken]];
    NSDictionary *postData = @{@"userId":userId};
    [[AFHTTPRequestOperationManager manager]POST:resetPasswordURL parameters:postData success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:RESETPASSWORD_COMPELETE_NOTIFICATION userInfo:[self packageingUserNotOwner:responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:RESETPASSWORD_COMPELETE_NOTIFICATION userInfo:nil];
    }];
}

-(void)modifyPassword:(UsersModel *)user
{
    NSDictionary *parame = @{@"oldPassword":[CommonHelper md5:user.password],@"newPassword":[CommonHelper md5:user.resetPassword]};
    passwordCompatable = @{[CommonHelper md5:user.resetPassword]:user.resetPassword};
    NSString *modifyURL = [NSString stringWithFormat:@"%@user/%@/%@",BASE_URL,[self getOwnId],[self getToken]];
    [[AFHTTPRequestOperationManager manager]POST:modifyURL parameters:parame success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:MODIFYPASSWORD_COMPLETE_NOTIFICATION userInfo:[self packagingDictionaryWithDictionary:responseObject]];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:MODIFYPASSWORD_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}

//个人修改用户信息接口(可能本人，可能非本人)
- (void)updateUserInfo:(UsersModel *)user
{
    NSString *updateURL = [NSString stringWithFormat:@"%@users/%@/edit/%@/%@",BASE_URL,[self getOwnId],PERSONAL_MODIFY_USER_INFO, [self getToken]];
    UsersModel *owner = [self getCurrentUser];
    NSString *appendCompany = [NSString stringWithFormat:@"{ \"na\" : \"%@\", \"de\" : \"%@\", \"po\" : \"%@\" }",user.companyName?user.companyName:@"",user.department.modelName?user.department.modelName:@"",user.companyPosition?user.companyPosition:@""];
    NSDictionary *postData = @{@"username":user.username?user.username:@"",@"phone":user.phone?user.phone:@"",@"departmentId":user.department.modelId,@"department":user.department.modelName?user.department.modelName:@"",@"company":appendCompany,@"needSignIn":[NSString stringWithFormat:@"%d",[owner.needSignIn intValue]],@"chartAuth":owner.chartAuth,@"manageDepartmentsAuth":owner.manageDepartmentsAuth,@"manageSubDepartmentsAuth":owner.manageSubDepartmentsAuth};
    [[AFHTTPRequestOperationManager manager]POST:updateURL parameters:postData success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:UPDATE_PERSONAL_USER_INFO_NOTIFICATION userInfo:[user.userId isEqualToString:[self getOwnId]]?[self packagingDictionaryWithDictionary:responseObject]:[self packageingUserNotOwner:responseObject]];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:UPDATE_PERSONAL_USER_INFO_NOTIFICATION userInfo:nil];
    }];
}

- (void)ManageUserInfo:(UsersModel *)user
{
    NSString *updateURL = [NSString stringWithFormat:@"%@users/%@/edit/%@/%@",BASE_URL,user.userId,ADMINISTRATOR_MODIFY_USER_INFO, [self getToken]];
    NSString *appendCompany = [NSString stringWithFormat:@"{ \"na\" : \"%@\", \"de\" : \"%@\", \"po\" : \"%@\" }",user.companyName?user.companyName:@"",user.department.modelName?user.department.modelName:@"",user.companyPosition?user.companyPosition:@""];
    NSDictionary *postData = @{@"username":user.username?user.username:@"",@"phone":user.phone?user.phone:@"",@"departmentId":user.department.modelId,@"department":user.department.modelName?user.department.modelName:@"",@"company":appendCompany,@"needSignIn":[NSString stringWithFormat:@"%d",[user.needSignIn intValue]],@"chartAuth":user.chartAuth,@"manageDepartmentsAuth":user.manageDepartmentsAuth,@"manageSubDepartmentsAuth":user.manageSubDepartmentsAuth};
    [[AFHTTPRequestOperationManager manager]POST:updateURL parameters:postData success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:MANAGE_USER_INFO_NOTIFICATION userInfo:[self packageingUserNotOwner:responseObject]];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:MANAGE_USER_INFO_NOTIFICATION userInfo:nil];
    }];
}

-(void)editUserInfo:(UsersModel *)user
{
    NSString *editURL = [NSString stringWithFormat:@"%@users/%@/edit",BASE_URL,[self getOwnId]];
    NSString *appendCompany = [NSString stringWithFormat:@"{ \"na\" : \"%@\", \"de\" : \"%@\", \"po\" : \"%@\" }",user.companyName?user.companyName:@"",user.companyDepartment?user.companyDepartment:@"",user.companyPosition?user.companyPosition:@""];
    
    NSDictionary *postData = @{@"username":user.username,@"phone":user.phone,@"company":appendCompany,@"deviceId":[self getDeviceId],@"department":user.companyDepartment,@"departmentId":user.department.modelId};
    
    [[AFHTTPRequestOperationManager manager]POST:editURL parameters:postData success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:EDITUSER_COMPLETE_NOTIFICATION userInfo:[self packageingUserNotOwner:responseObject]];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:EDITUSER_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}

- (void)addUserInfo:(UsersModel *)user
{
    NSString *addUserURL = [NSString stringWithFormat:@"%@users/add/%@",BASE_URL,[self getToken]];
    NSString *appendCompany = [NSString stringWithFormat:@"{ \"na\" : \"%@\", \"de\" : \"%@\", \"po\" : \"%@\" }",user.companyName?user.companyName:@"",user.department.modelName?user.department.modelName:@"",user.companyPosition?user.companyPosition:@""];
    NSDictionary *postData = @{@"email":user.email?user.email:@"",@"pwd":[CommonHelper md5:@"123456"],@"username":user.username?user.username:@"",@"phone":user.phone?user.phone:@"",@"deptId":user.department.modelId,@"deptName":user.department.modelName?user.department.modelName:@"",@"company":appendCompany,@"chartAuth":user.chartAuth,@"manageDepartmentsAuth":user.manageDepartmentsAuth,@"manageSubDepartmentsAuth":user.manageSubDepartmentsAuth,@"needSignIn":user.needSignIn};
    [[AFHTTPRequestOperationManager manager] POST:addUserURL parameters:postData success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [CommonHelper postNotification:ADD_USER_INFO_NOTIFICATION userInfo:[self packingUserWhenAddUser:responseObject]];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:ADD_USER_INFO_NOTIFICATION userInfo:nil];
    }];

}

-(void)findDepartmentUsers:(NSString *)departmentId
{
    NSString * departmentUsersUrl = [NSString stringWithFormat:@"%@users/lower/%@/%@/%@",BASE_URL, departmentId, [self getOwnId], [self getToken]];
    [[AFHTTPRequestOperationManager manager]GET:departmentUsersUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrUsers =responseObject[@"resultData"];
            if (arrUsers) {
                [arrUsers enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    UsersModel *user = [[UsersModel alloc]init];
                    [resultArr addObject:[user fromDictionary:obj]];
                }];
            }
        }
        [CommonHelper postNotification:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}

- (void)deleteUser:(UsersModel *)user
{
    NSString *deleteUserURL = [NSString stringWithFormat:@"%@user/delete/%@",BASE_URL,[self getToken]];
    NSDictionary *tempDict = @{@"userId":user.userId};
    [[AFHTTPRequestOperationManager manager] POST:deleteUserURL parameters:tempDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            CDUserDAO *userDAO = [[CDUserDAO alloc] init];
            [userDAO deleteById:user.userId];
        }
        [CommonHelper postNotification:DELETE_USER_COMPLETE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":@""}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:DELETE_USER_COMPLETE_NOTIFICATION userInfo:nil];
    }];
}

///////////////////////////////////////////  1 -- 考勤 2 －－－外访
///////////报表部分/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getUserChartsWithUserId:(NSString *)userId beginDate:(NSString *)beginDate endDate:(NSString *)endDate chartType:(CHART_TYPE)type
{
    NSString *getChartURL = [NSString stringWithFormat:@"%@chart/%@",BASE_URL,[self getToken]];
    NSDictionary *postData = @{@"beginDate":beginDate,@"endDate":endDate,@"userId":userId,@"type":@(type)};
    
    [[AFHTTPRequestOperationManager manager] GET:getChartURL parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"某人考勤报表 = %@",responseObject);
        switch (type) {
            case CHART_TYPE_ATTENDANCE:
                [CommonHelper postNotification:GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION userInfo:responseObject];
                break;
                
            case CHART_TYPE_VISIT:
                [CommonHelper postNotification:GET_USER_VISIT_CHART_MONTH_NOTIFICATION userInfo:responseObject];
                break;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        switch (type) {
            case CHART_TYPE_ATTENDANCE:
                [CommonHelper postNotification:GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION userInfo:nil];
                break;
                
            case CHART_TYPE_VISIT:
                [CommonHelper postNotification:GET_USER_VISIT_CHART_MONTH_NOTIFICATION userInfo:nil];
                break;
        }
    }];
}

/*
- (void)getUserMonthAttendanceChartWithUserId:(NSString *)userId andDate:(NSString *)date
{
    NSString *getChartURL = [NSString stringWithFormat:@"%@signchart/%@/%@/%@",BASE_URL,date,userId,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:getChartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"某人考勤报表 = %@",responseObject);
        [CommonHelper postNotification:GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION userInfo:nil];
    }];
}

- (void)getUserMonthVisitChartWithUserId:(NSString *)userId andDate:(NSString *)date
{
    NSString *getChartURL = [NSString stringWithFormat:@"%@visitchart/%@/%@/%@",BASE_URL,date,userId,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:getChartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"某人外访报表 = %@",responseObject);
        [CommonHelper postNotification:GET_USER_VISIT_CHART_MONTH_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:GET_USER_VISIT_CHART_MONTH_NOTIFICATION userInfo:nil];
    }];
}
*/
////////////

- (void)unlockAcountWithUserId:(NSString *)userId
{
    NSString *unlockURL = [NSString stringWithFormat:@"%@user/unbind/%@",BASE_URL,[self getToken]];
    NSDictionary *postData = @{@"userId":userId};
    [[AFHTTPRequestOperationManager manager] POST:unlockURL parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [CommonHelper postNotification:UNLOCK_ACOUNT_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:UNLOCK_ACOUNT_NOTIFICATION userInfo:nil];
    }];
}

#pragma mark -
#pragma mark helper
- (NSDictionary *)packageingUserNotOwner:(NSDictionary *)responseObject
{
    NSString *resultCode = responseObject[@"resultCode"];
    NSString *resultDescription = responseObject[@"resultDescription"];
    UsersModel *user = [[UsersModel alloc]init];
    if (resultCode && [resultCode hasPrefix:@"I"]) {
        NSDictionary *userDic =responseObject[@"resultData"];
        if (userDic) {
            [user fromDictionary:userDic];
            if (!user.deviceId) {
                user.deviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
            }
            CDUserDAO *userDAO = [[CDUserDAO alloc] init];
            [userDAO update:userDic];
        }
    }
    return @{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":user};
}

- (NSDictionary *)packingUserWhenAddUser:(NSDictionary *)responseObject
{
    NSString *resultCode = responseObject[@"resultCode"];
    NSString *resultDescription = responseObject[@"resultDescription"];
    UsersModel *user = [[UsersModel alloc]init];
    if (resultCode && [resultCode hasPrefix:@"I"]) {
        NSDictionary *userDic =responseObject[@"resultData"];
        if (userDic) {
            [user fromDictionary:userDic];
            if (!user.deviceId) {
                user.deviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
            }
            CDUserDAO *userDAO = [[CDUserDAO alloc] init];
            [userDAO save:userDic];
        }
    }
    return @{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":user};
}

- (NSDictionary *)packagingDictionaryWithDictionary:(NSDictionary *)responseObject
{
    NSString *resultCode = responseObject[@"resultCode"];
    NSString *resultDescription = responseObject[@"resultDescription"];
    UsersModel *user = [[UsersModel alloc]init];
    if (resultCode && [resultCode hasPrefix:@"I"]) {
        NSDictionary *userDic =responseObject[@"resultData"];
        if (userDic) {
            [user fromDictionary:userDic];
            if (!user.deviceId) {
                user.deviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
            }
            CDUserDAO *userDAO = [[CDUserDAO alloc] init];
            [userDAO update:userDic];
            [self saveCurrentUser:user];
        }
    }
    return @{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":user};
}

-(void)saveCurrentUser:(UsersModel *)user
{
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    user.password = passwordCompatable[user.password];
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [defaults setObject:encodedUser forKey:@"currentUser"];
    [defaults synchronize];
}
@end
