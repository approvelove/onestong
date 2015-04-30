//
//  ModifyPasswordViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "VerifyHelper.h"
#import "UsersService.h"

@interface ModifyPasswordViewController ()
{
    __weak IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UITextField *currentPassword;
    __weak IBOutlet UITextField *newPassword;
    __weak IBOutlet UITextField *repeatPassword;
}
@end

@implementation ModifyPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initModifyPasswordViewController];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self freeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self freeNotification];
}

#pragma mark -
#pragma mark 界面逻辑处理
- (void)sendRequestModifyPassword:(UsersModel *)model
{
    [self startLoading:@"正在修改密码..."];
    UsersService *userService = [[UsersService alloc] init];
    [userService modifyPassword:model];
}


- (void)modifyPasswordComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self toast:@"密码修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark 界面事件处理

- (void)confirmButtonClick
{
    if ([VerifyHelper isEmpty:currentPassword.text]||[VerifyHelper isEmpty:newPassword.text]||[VerifyHelper isEmpty:repeatPassword.text]) {
        return;
    }
    if (![newPassword.text isEqualToString:repeatPassword.text]) {
        [self showAlertwithTitle:@"两次输入密码不一致"];
        return;
    }
    if ([newPassword.text isEqualToString:currentPassword.text]) {
        [self showAlertwithTitle:@"新密码不能与旧密码相同"];
        return;
    }
    UsersModel *userModel = [[UsersModel alloc]init];
    userModel.password = currentPassword.text;
    userModel.resetPassword = newPassword.text;
    [self sendRequestModifyPassword:userModel];
    
}

#pragma mark -
#pragma mark 代理


#pragma mark -
#pragma mark 界面操作
- (void)initModifyPasswordViewController
{
    self.navigationItem.title = @"修改密码";
    [self newRightButtonItem];
}

- (void)newRightButtonItem
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}


#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyPasswordComplete:) name:MODIFYPASSWORD_COMPLETE_NOTIFICATION object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYPASSWORD_COMPLETE_NOTIFICATION object:nil];
}
@end
