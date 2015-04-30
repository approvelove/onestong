//
//  MyProfileViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//



#import "MyProfileViewController.h"
#import "EditInformationViewController.h"
#import "ModifyPasswordViewController.h"
#import "LoginViewController.h"
#import "OrganizeViewController.h"
#import "DepartmentAndUserViewController.h"
#import "UsersService.h"
#import "TimeSetViewController.h"
#import "VerifyHelper.h"

@interface MyProfileViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSDictionary *myProfileFunction;
    __weak IBOutlet UITableView *mainTable;
    NSDictionary *functionNameArray;
}
@end

@implementation MyProfileViewController

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
    // Do any additional setup after loading the view from its nib.
    [self initMyProfileFunction];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 界面操作
- (void)initMyProfileFunction
{
    self.navigationItem.title = @"个人中心";
    UsersService *service = [[UsersService alloc] init];
    UsersModel *model = [service getCurrentUser];
    if (myProfileFunction == nil) {
        myProfileFunction = ([VerifyHelper isEmpty:model.manageDepartmentsAuth])?@{@"个人中心":@[@"修改密码",@"编辑个人信息",@"注销"]}:@{@"个人中心":@[@"修改密码",@"编辑个人信息",@"注销"],@"管理":@[@"部门及成员管理",@"工作时间设定"]};
    }
    if (functionNameArray == nil) {
        functionNameArray = ([VerifyHelper isEmpty:model.manageDepartmentsAuth])?@{@"个人中心":@[@"modifyPasswordbuttonClick",@"editPersonInfomationClick",@"logOut"]}:@{@"个人中心":@[@"modifyPasswordbuttonClick",@"editPersonInfomationClick",@"logOut"],@"管理":@[@"departmentAndUserManagement",@"modifyWorkTime"]};
    }
}

#pragma mark -
#pragma mark 界面逻辑处理


#pragma mark -
#pragma mark 界面事件处理
- (void)modifyWorkTime
{
    NSLog(@"修改时间");
    TimeSetViewController *timeSet = [[TimeSetViewController alloc] initWithNibName:@"TimeSetViewController" bundle:nil];
    [self.navigationController pushViewController:timeSet animated:YES];
}

- (void)modifyPasswordbuttonClick
{
    ModifyPasswordViewController *modifyPassword = [[ModifyPasswordViewController alloc] initWithNibName:@"ModifyPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:modifyPassword animated:YES];
}

- (void)editPersonInfomationClick
{
    NSLog(@"编辑个人信息");
    EditInformationViewController *editCtrl = [[EditInformationViewController alloc] initWithNibName:@"EditInformationViewController" bundle:nil];
    
    [self.navigationController pushViewController:editCtrl animated:YES];
}

- (void)logOut
{
    NSLog(@"注销");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)departmentAndUserManagement
{
    DepartmentAndUserViewController *dptVC = [[DepartmentAndUserViewController alloc] initWithNibName:@"DepartmentAndUserViewController" bundle:nil];
    [self.navigationController pushViewController:dptVC animated:YES];
}

#pragma mark -
#pragma mark 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[myProfileFunction allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (myProfileFunction) {
        return [myProfileFunction[[myProfileFunction allKeys][section]] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (myProfileFunction) {
        return [myProfileFunction allKeys][section];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellone"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString * labelText = myProfileFunction[[myProfileFunction allKeys][indexPath.section]][indexPath.row];
    cell.textLabel.text = labelText;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:NSSelectorFromString(functionNameArray[[functionNameArray allKeys][indexPath.section]][indexPath.row])]) {
        [self performSelector:NSSelectorFromString(functionNameArray[[functionNameArray allKeys][indexPath.section]][indexPath.row]) withObject:nil afterDelay:0.f];
    }
}

@end
