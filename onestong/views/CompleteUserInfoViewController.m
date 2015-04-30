//
//  CompleteUserInfoViewController.m
//  onestong
//
//  Created by 李健 on 14-5-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CompleteUserInfoViewController.h"
#import "EditInformationViewController.h"
#import "UsersService.h"
#import "VerifyHelper.h"
#import "DepartmentListViewController.h"
#import "CDDepartment.h"

@interface CompleteUserInfoViewController ()<UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UITextField *phoneNumber;
    __weak IBOutlet UITextField *company;
    __weak IBOutlet UIButton *departmentBtn;
    __weak IBOutlet UITextField *position;
    __weak IBOutlet UIView *formOne;
    __weak IBOutlet UIView *formTwo;
    CDDepartment *currentDepartment;
}
@end

@implementation CompleteUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark -
#pragma mark 系统操作

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initCompleteUserInfoViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registNotification];
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
#pragma mark 事件处理

- (void)selectedDepartmentOver:(NSNotification *)notification
{
    currentDepartment = notification.userInfo[@"resultData"];
    [departmentBtn setTitle:currentDepartment.deptname forState:UIControlStateNormal];
}

- (IBAction)cancelUserInfoViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectDepartmentButtonClick:(id)sender
{
    DepartmentListViewController *departmentCV = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    UsersModel *user = [[[UsersService alloc] init] getCurrentUser];
    departmentCV.findRange = FIND_DATA_ALL;
    if (currentDepartment) {
        departmentCV.departmentId = currentDepartment.deptId;
    }
    else
    {
        departmentCV.departmentId = user.department.modelId;
    }
    [self presentViewController:departmentCV animated:YES completion:nil];
}

- (IBAction)completeUserInfoViewController
{
    NSLog(@"save");
    if ([VerifyHelper isEmpty:name.text]||[VerifyHelper isEmpty:phoneNumber.text]||[VerifyHelper isEmpty:company.text]||[VerifyHelper isEmpty:departmentBtn.titleLabel.text]||[VerifyHelper isEmpty:position.text]) {
        [self showAlertwithTitle:@"请完善个人信息后再提交，谢谢您的配合!"];
        return;
    }
    [self sendRequestEditUserInfomation];
}

#pragma mark -
#pragma mark 逻辑处理

- (void)sendRequestEditUserInfomation
{
    [self startLoading:@"正在完善个人信息..."];
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    userModel.username = name.text;
    userModel.phone = phoneNumber.text;
    userModel.companyName = company.text;
    userModel.companyDepartment = departmentBtn.titleLabel.text;
    userModel.companyPosition = position.text;
    if (currentDepartment) {
        userModel.department.modelId = currentDepartment.deptId;
    }
    [userService editUserInfo:userModel];
}

- (void)editUserComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary * dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETEUSERINFO object:nil userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark -
#pragma mark 界面处理

- (void)initCompleteUserInfoViewController
{
    [self registFormScrollView:mainScroll];
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    if (userModel.companyName&&(userModel.companyName.length>0)) {
        company.text = userModel.companyName;
    }
    if (userModel.department.modelName&&(userModel.department.modelName.length>0)) {
        [departmentBtn setTitle:userModel.department.modelName forState:UIControlStateNormal];
    }
    if (userModel.companyPosition&&(userModel.companyPosition.length>0)) {
        position.text = userModel.companyPosition;
    }
}
#pragma mark -
#pragma mark 代理
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    mainScroll.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    for (UITextField *txtField in [formOne subviews]) {
        if ([txtField isMemberOfClass:[UITextField class]]) {
            [txtField resignFirstResponder];
        }
    }
    for (UITextField *txtField in [formTwo subviews]) {
        if ([txtField isMemberOfClass:[UITextField class]]) {
            [txtField resignFirstResponder];
        }
    }
}

#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserComplete:) name:EDITUSER_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDepartmentOver:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
}
-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDITUSER_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
}
@end
