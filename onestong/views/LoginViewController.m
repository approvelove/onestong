//
//  LoginViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "GraphicHelper.h"
#import "CommonHelper.h"
#import "VerifyHelper.h"
#import "UsersService.h"
#import "UsersModel.h"
#import "CompleteUserInfoViewController.h"
#import "DataUpdateService.h"
#import "TimeSetSerivce.h"
#import "TimeSetModel.h"
#import "TimeHelper.h"
#import "AppDelegate.h"
#import "VersionCheckService.h"
#import "VersionModel.h"
#import "EventsService.h"


static NSString * const TIME_WORK_NOTICE = @"已接近上班时间，没签到的同事别忘了哦";
static NSString * const TIME_ENDOFWORK_NOTICE = @"下班啦，别忘了签退哦";

typedef NS_ENUM(NSInteger, WEEKDAY) {
    WEEKDAY_MONDAY=0,
    WEEKDAY_TUESDAY,
    WEEKDAY_WEDNESDAY,
    WEEKDAY_THURSDAY,
    WEEKDAY_FRIDAY,
};

@interface LoginViewController ()
{
    __weak IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UIView *bgView;
    __weak IBOutlet UIView *bgPasswordAndEmail;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtPassword;
    VersionModel *versionModel;
}
@end

@implementation LoginViewController

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
    [self initLoginView];
    [self registNotification];
    [self registVersionCheckNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [self loadEmail];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self freeNotification];
    [self freeVersionCheckNotification];
}

#pragma mark -
#pragma mark 登录界面 事件操作

- (IBAction)resetPasswordButtonClick:(id)sender
{
    NSLog(@"reset password");
}

-(IBAction)loginButtonClick:(id)sender
{
    [self versionCheckRequest];
}

#pragma mark -
#pragma mark 登录界面 数据展示操作
-(void)loginComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary * dic = notification.userInfo;
    if ([self doResponse:dic]) {
        UsersModel *userModel = dic[@"resultData"];
        [self sendRequestFindAllTime];
        if ([userModel.validSign isEqualToString:@"1"]) { //未激活
            [self pushViewControllerCompleteUserInfo];
        }
        else
        {
            HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            [self.navigationController pushViewController:homeVC animated:YES];
        }
    }
}


#pragma mark -
#pragma mark 登录界面 逻辑操作

//本地推送注册
- (void)registLocalPushNotificationWithFireTime:(NSDate *)fireTime message:(NSString *)message
{
    NSLog(@"fireTime = %@",fireTime);
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *locationNo = [[UILocalNotification alloc] init];
    locationNo.fireDate = fireTime;
    locationNo.timeZone = [NSTimeZone defaultTimeZone];
    locationNo.repeatInterval = NSWeekCalendarUnit;
    locationNo.soundName = UILocalNotificationDefaultSoundName;
    locationNo.hasAction = YES;
//    locationNo.alertLaunchImage = @"baidumap_logo";
    locationNo.alertBody = message;
    locationNo.applicationIconBadgeNumber = 1;
    locationNo.userInfo = @{@"key":@"签到/签退"};
    [app scheduleLocalNotification:locationNo];
}

//版本管理
- (void)versionCheckRequest
{
    [self startLoading:@"正在进行版本校验..."];
    VersionCheckService *versionCheck = [[VersionCheckService alloc] init];
    [versionCheck checkVersion];
}


- (void)versionCheckComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSDictionary *infoDic = notification.userInfo;
    if ([self doResponse:infoDic]) {
        NSArray *versionAry = infoDic[@"resultData"];
        if (versionAry &&versionAry.count>0) {
            versionModel = versionAry[0];
            if ([versionModel.versionCode isEqualToString:version]) {
                [self loginWithEmail:txtEmail.text andPasswrod:txtPassword.text];
            }
            else
            {
                if (versionModel.versionUpdateLevel == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"存在新的版本更新,建议您前往更新" delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"前往更新", nil];
                    alert.tag = 0;
                    [alert show];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"存在重要的版本升级，如果不更新程序将在3秒后退出" delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"前往更新", nil];
                    alert.tag = 1;
                    [alert show];
                }
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 0) {
            [self loginWithEmail:txtEmail.text andPasswrod:txtPassword.text];
        }
        else
        {
            exit(3);
        }
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionModel.downLoadURL]];
    }
}
///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////




- (void)sendRequestFindAllTime
{
    TimeSetSerivce *service = [[TimeSetSerivce alloc] init];
    [service findAllWorkTime];
}

-(void)departmentsUpdateComplete:(NSNotification *)notification
{
    [self stopLoading];
    [self sendRequestFindEventList];
}

-(void)usersUpdateComplete:(NSNotification *)notification
{
    [self stopLoading];
    DataUpdateService *dataUpdateService = [[DataUpdateService alloc]init];
    [dataUpdateService updateDepartmentsData];
//    [self startLoading:@"正在更新部门数据"];
}

-(void)dataUpdate
{
    DataUpdateService *dataUpdateService = [[DataUpdateService alloc]init];
    [dataUpdateService updateUsersData];
//    [self startLoading:@"正在更新用户数据"];
}

-(void)loginWithEmail:(NSString *)email andPasswrod:(NSString *)password
{
    if ([VerifyHelper isEmpty:email]) {
        [CommonHelper alert:@"请输入邮箱"];
        return;
    }
    if ([VerifyHelper isEmpty:password]) {
        [CommonHelper alert:@"请输入密码"];
        return;
    }
    
    UsersService * usersService = [[UsersService alloc]init];
    UsersModel *user = [[UsersModel alloc]initWithEmail:email andPassword:password];
    [self startLoading:@"正在进行登录验证..."];
    [usersService login:user];
}

-(void)loadEmail
{
    UsersService * usersService = [[UsersService alloc]init];
    NSString * email = [usersService getEmail];
    if (email) {
        txtEmail.text = email;
    }
    txtPassword.text = [usersService getPassWord];
//#ifdef DEBUG
//    txtEmail.text = @"wei.liang@mc2.cn";
//    txtPassword.text = @"123456";
//#endif
}


- (void)userInfomationComplete
{
    HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:homeVC animated:NO];
}

- (void)timeSetRequestComplete:(NSNotification *)notification
{
    NSArray *tempAry = [self doResponse:notification.userInfo];
    [self dataUpdate];
    if (tempAry&&tempAry.count>0) {
        TimeSetModel *model = [tempAry lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:model.endTime forKey:@"workEndTime"];
        [defaults synchronize];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            [self runDeviceLocationWithStartTime:model.startTime endtime:model.endTime];
        });
    }
    else{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            [self runDeviceLocationWithStartTime:@"09:00" endtime:@"18:00"];
        });
    }
}


//发送用户设备轨迹入口   该入口目前已停用

//- (void)runDeviceLocationWithStartTime:(NSString *)startTimeStr endtime:(NSString *)endTimeStr
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm"];
//    NSDate *beginDate = [dateFormatter dateFromString:startTimeStr];
//    NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
//    long long startTime = [TimeHelper convertDateToSecondTime:beginDate];
//    long long endTime = [TimeHelper convertDateToSecondTime:endDate];
//    
//    [self registLocalPushNotificationWithStartTime:startTimeStr endTime:endTimeStr];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate runThreadOnBackgroundWithStartTime:startTime endTime:endTime];
//}

- (void)registLocalPushNotificationWithStartTime:(NSString *)start endTime:(NSString *)end
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (int i = 0; i<5; i++) {
        NSDate *startDate = [self appendWeekTimeToTimeString:start withWeekName:i];
        NSDate *endDate = [self appendWeekTimeToTimeString:end withWeekName:i];
        long long startTime = [TimeHelper convertDateToSecondTime:startDate];
        long long noticeMM = startTime - 10*60*1000;
        NSDate *noticeDate = [TimeHelper convertSecondsToDate:noticeMM];
        [self registLocalPushNotificationWithFireTime:noticeDate message:TIME_WORK_NOTICE];//签到提醒
        
        [self registLocalPushNotificationWithFireTime:endDate message:TIME_ENDOFWORK_NOTICE];//签退提醒
    }
}

- (NSDate *)appendWeekTimeToTimeString:(NSString *)timeStr withWeekName:(WEEKDAY)weekDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm EEEE"];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    NSMutableString *tempStr = [timeStr mutableCopy];
    switch (weekDay) {
        case WEEKDAY_MONDAY:
            [tempStr appendString:@" 星期一"];
            break;
        case WEEKDAY_TUESDAY:
            [tempStr appendString:@" 星期二"];
            break;
        case WEEKDAY_WEDNESDAY:
            [tempStr appendString:@" 星期三"];
            break;
        case WEEKDAY_THURSDAY:
            [tempStr appendString:@" 星期四"];
            break;
        case WEEKDAY_FRIDAY:
            [tempStr appendString:@" 星期五"];
            break;
    }
    NSDate *dateTime = [dateFormatter dateFromString:tempStr];
    return dateTime;
}

- (void)sendRequestFindEventList
{
    EventsService *service = [[EventsService alloc] init];
    [service findEventList];
}

- (void)findEventListOver:(NSNotification *)notification
{
    NSArray *eventListAry = [self doResponse:notification.userInfo];
    if (eventListAry) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:eventListAry forKey:@"eventList"];
        [defaults synchronize];
    }
}
#pragma mark -
#pragma mark 代理
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    mainScroll.scrollEnabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    mainScroll.scrollEnabled = NO;
}

#pragma mark -
#pragma mark 界面处理

- (void)initLoginView
{
    [self resizeMainScroll];
    mainScroll.scrollEnabled = NO;
    
    [GraphicHelper convertRectangleToEllipses:bgPasswordAndEmail withBorderColor:rgbaColor(204.f, 204.f, 204.f, 1.f) andBorderWidth:1.f andRadius:3.f];
    [GraphicHelper convertRectangleToEllipses:btnLogin withBorderColor:[UIColor clearColor] andBorderWidth:0.f andRadius:3.f];
    [self registFormScrollView:mainScroll];
}

- (void)resizeMainScroll
{
    NSLayoutConstraint *ss = [NSLayoutConstraint constraintWithItem:bgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CURRENT_DEVICE_HEIGHT];
    [bgView addConstraint:ss];
}

- (void)pushViewControllerCompleteUserInfo
{
    CompleteUserInfoViewController *completeInfo = [[CompleteUserInfoViewController alloc] initWithNibName:@"CompleteUserInfoViewController" bundle:nil];
    [self presentViewController:completeInfo animated:YES completion:nil];
}

#pragma mark -
#pragma mark 视图通知管理
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete:) name:LOGIN_COMPELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfomationComplete) name:NOTIFICATION_COMPLETEUSERINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersUpdateComplete:) name:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentsUpdateComplete:) name:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeSetRequestComplete:) name:NOTIFICATION_FIND_ALL_TIME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findEventListOver:) name:FIND_EVENT_LIST_NOTIFICATION object:nil];
}

-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_COMPELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_COMPLETEUSERINFO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FIND_ALL_TIME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_EVENT_LIST_NOTIFICATION object:nil];
}

- (void)registVersionCheckNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(versionCheckComplete:) name:NOTIFICATION_VERSION_CHECK object:nil];
}
- (void)freeVersionCheckNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_VERSION_CHECK object:nil];
}

@end
