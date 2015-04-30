//
//  EditInformationViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "EditInformationViewController.h"
#import "UsersService.h"
#import "VerifyHelper.h"
#import "DepartmentListViewController.h"
#import "CDDepartment.h"
#import "CDDepartmentDAO.h"

@interface EditInformationViewController ()
{
    __weak IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UITextField *phoneNumber;
    __weak IBOutlet UITextField *company;
    __weak IBOutlet UIButton *departmentButton;
    __weak IBOutlet UITextField *position;
    CDDepartment *currentSelectedDepartment;
}
@end

@implementation EditInformationViewController

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
   
    [self initEditInfomationViewController];
    [self registNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
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
#pragma mark 界面操作

- (void)newRightButtonItem
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)initEditInfomationViewController
{
    self.navigationItem.title = @"编辑个人信息";
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
    currentSelectedDepartment = [deptDAO findById:userModel.department.modelId];
    name.text = userModel.username;
    phoneNumber.text = userModel.phone;
    company.text = userModel.companyName;
    if (![VerifyHelper isEmpty:departmentButton.titleLabel.text]) {
        [departmentButton setTitle:userModel.department.modelName forState:UIControlStateNormal];
    }
    position.text = userModel.companyPosition;
    [self newRightButtonItem];
    [self registFormScrollView:mainScroll];
}


#pragma mark -
#pragma mark 界面逻辑处理
- (void)editUserComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary * dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self toast:@"用户信息修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sendRequestEditUserInfomation
{
    [self startLoading:@"正在更新用户信息..."];
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    userModel.username = name.text;
    userModel.phone = phoneNumber.text;
    userModel.companyName = company.text;
    userModel.companyDepartment = currentSelectedDepartment.deptname;
    userModel.department.modelId = currentSelectedDepartment.deptId;
    userModel.companyPosition = position.text;
    userModel.department.modelName = currentSelectedDepartment.deptname;
    [userService updateUserInfo:userModel];
}

- (void)selectedDepartmentComplete:(NSNotification *)notification
{
    if (notification.userInfo[@"resultData"]) {
        currentSelectedDepartment = notification.userInfo[@"resultData"];
        [departmentButton setTitle:currentSelectedDepartment.deptname forState:UIControlStateNormal];
    }
}
#pragma mark -
#pragma mark 界面事件处理

- (void)saveButtonClick
{
    NSLog(@"save");
    if ([VerifyHelper isEmpty:name.text]||[VerifyHelper isEmpty:phoneNumber.text]||[VerifyHelper isEmpty:company.text]||[VerifyHelper isEmpty:departmentButton.titleLabel.text]||[VerifyHelper isEmpty:position.text]) {
        [self showAlertwithTitle:@"您还存在未填写信息"];
        return;
    }
    [self sendRequestEditUserInfomation];
}

- (IBAction)selectDepartmentButtonClick
{
    DepartmentListViewController *departmentList = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    departmentList.findRange = FIND_DATA_ALL;
    departmentList.departmentId = userModel.department.modelId;
    [self presentViewController:departmentList animated:YES completion:nil];
}
#pragma mark -
#pragma mark 代理

#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserComplete:) name:UPDATE_PERSONAL_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDepartmentComplete:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
}
-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_PERSONAL_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
}
@end
