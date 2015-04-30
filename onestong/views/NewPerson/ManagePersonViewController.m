//
//  ManagePersonViewController.m
//  onestong
//
//  Created by 李健 on 14-5-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "ManagePersonViewController.h"
#import "CDUser.h"
#import "UsersService.h"
#import "GraphicHelper.h"
#import <MessageUI/MessageUI.h>
#import "VerifyHelper.h"

@interface ManagePersonViewController ()<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *companyLabel;
    __weak IBOutlet UILabel *departmentLabel;
    __weak IBOutlet UILabel *positionLabel;
    __weak IBOutlet UIButton *phoneBtn;
    __weak IBOutlet UIButton *emailBtn;
    
    __weak IBOutlet UILabel *chartAuth;
    __weak IBOutlet UILabel *manageDepartmentAuth;
    __weak IBOutlet UILabel *manageSubDepartmentAuth;
    
    __weak IBOutlet UIButton *resetPsdBtn;
    __weak IBOutlet UIButton *unlockButton;
}
@end

@implementation ManagePersonViewController
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - 
#pragma mark 系统方法

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initManagePersonViewController];
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
- (IBAction)resetPasswordButtonClick:(UIButton *)sender
{
    [self startLoading:@"正在重置密码..."];
    UsersService *service = [[UsersService alloc] init];
    [service resetPasswordWithUserId:self.user.userId];
}

- (IBAction)unlockDeviceButtonClick:(id)sender
{
    [self startLoading:@"正在解绑设备..."];
    UsersService *service = [[UsersService alloc] init];
    [service unlockAcountWithUserId:self.user.userId];
}

- (IBAction)telButtonClick:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"如果您想拨打该电话号码请点击“拨打”" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拨打", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)emailButtonClick:(id)sender
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    picker.mailComposeDelegate = self;
    [picker setSubject:@""];
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:self.user.email];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark -
#pragma mark 逻辑处理
- (void)resetPasswordComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self toast:@"密码已重置"];
    }
}

- (void)unlockDeviceComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self toast:@"该账号已解除设备绑定"];
    }
}

#pragma mark -
#pragma mark 界面处理
- (void)initManagePersonViewController
{
    self.navigationItem.title = self.user.username;
    [GraphicHelper convertRectangleToEllipses:resetPsdBtn withBorderColor:nil andBorderWidth:0 andRadius:3];
    [GraphicHelper convertRectangleToEllipses:unlockButton withBorderColor:nil andBorderWidth:0 andRadius:3];
//    [self addEditButtonOnRightNavBar];
    if (self.user.username&&self.user.username.length>0) {
        nameLabel.text = self.user.username;
    }
    if (self.user.companyName&&self.user.companyName.length>0) {
        companyLabel.text = self.user.companyName;
    }
    if (self.user.departmentName&&self.user.departmentName.length>0) {
        departmentLabel.text = self.user.departmentName;
    }
    if (self.user.companyPosition&&self.user.companyPosition.length>0) {
        positionLabel.text = self.user.companyPosition;
    }
    if (self.user.phone&&self.user.phone.length>0) {
        [phoneBtn setTitle:[self separatePhoneWithPhoneNum:self.user.phone] forState:UIControlStateNormal];
    }
    if (self.user.email&&self.user.email.length>0) {
        [emailBtn setTitle:self.user.email forState:UIControlStateNormal];
    }
    if (![VerifyHelper isEmpty:self.user.ca]) {
        chartAuth.text = @"打开";
    }
    if (![VerifyHelper isEmpty:self.user.da]) {
        manageDepartmentAuth.text = @"打开";
    }
    if ([self.user.needSignIn isEqualToNumber:[NSNumber numberWithInt:1]]) {
        manageSubDepartmentAuth.text = @"打开";
    }
}

- (NSString *)separatePhoneWithPhoneNum:(NSString *)phoneNum
{
    if (!phoneNum||phoneNum.length<11) {
        return @"";
    }
    NSString *stringFirst = [phoneNum substringWithRange:NSMakeRange(0, 3)];
    NSString *stringSecond = [phoneNum substringWithRange:NSMakeRange(3, 4)];
    NSString *stringThird = [phoneNum substringWithRange:NSMakeRange(7, 4)];
    NSString *resultStr = [NSString stringWithFormat:@"%@-%@-%@",stringFirst,stringSecond,stringThird];
    return resultStr;
}

//- (void)addEditButtonOnRightNavBar
//{
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeEditUserPermission)];
//    self.navigationItem.rightBarButtonItem = rightItem;
//}

#pragma mark -
#pragma mark 代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.user.phone]]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark 通知管理

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPasswordComplete:) name:RESETPASSWORD_COMPELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockDeviceComplete:) name:UNLOCK_ACOUNT_NOTIFICATION object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RESETPASSWORD_COMPELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNLOCK_ACOUNT_NOTIFICATION object:nil];
}
@end
