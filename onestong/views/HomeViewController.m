//
//  HomeViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "HomeViewController.h"
#import "GraphicHelper.h"
#import "SignContentViewController.h"
#import "EventsBoxViewController.h"
#import "MyProfileViewController.h"
#import "SettingViewController.h"
#import "SubSignDetailViewController.h"
#import "EventsService.h"
//#import "UIView+screenshot.h"
#import "UIView+Genie.h"
#import "TimeHelper.h"
#import "DepartmentOnlyViewController.h"
#import "VerifyHelper.h"
#import "OrganizeViewController.h"
#import "CDDepartmentDAO.h"
#import "CDUserDAO.h"
#import "CDUser.h"

#define COLOR_WHITE(W,A) [UIColor colorWithWhite:(W)/1.0f alpha:(A)/1.0f]

@import CoreLocation;
//#import "APLDefaults.h"

static float const  TIMER_AWEAK_INTERVAL = 1.f;

@interface HomeViewController ()<CLLocationManagerDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UIButton * btnSignIn;
    __weak IBOutlet UIButton * btnSignOut;
    __weak IBOutlet UILabel * lblDay;
    __weak IBOutlet UILabel * lblWeek;
    __weak IBOutlet UILabel * lblYearAndMonth;
    __weak IBOutlet UIToolbar * tlbHomeView;
    
    __weak IBOutlet UIView *topBgView;
    __weak IBOutlet UILabel *bgSignInLabel;
    __weak IBOutlet UILabel *bgSignOutLabel;
    
    __weak IBOutlet UIButton *helpBtn;
    
    __weak IBOutlet UIImageView *signInAttendanceImageView;
    __weak IBOutlet UIImageView *signOutAttendanceImageView;
    __weak IBOutlet NSLayoutConstraint *constraintTop;
    __weak IBOutlet UIImageView *tipImageView;
    BOOL signButtonClick;
    
    BOOL tipImageShow;
    
    BOOL validForSignIn;
}

@property NSMutableDictionary *beacons;
@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@end

@implementation HomeViewController

#pragma mark -
#pragma mark 重写系统界面操作
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tipImageShow = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    signButtonClick = NO;
    [self initHomeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    // 时间处理
    signButtonClick = NO;
    validForSignIn = NO;
    [self showCurrentDate];
    [self registNotification];
    [self showSignStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self startLocationWithBeacon];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self freeNotification];
    if (!tipImageView.hidden) {
        [self tipImageViewCloseAnn];
    }
//    [self stopLocationWithBeacon];
}

- (void)dealloc
{
    [self freeNotification];
}
#pragma mark -
#pragma mark 界面操作
- (void)enterOrganizerController
{
    OrganizeViewController *organizeViewController = [[OrganizeViewController alloc] initWithNibName:@"OrganizeViewController" bundle:nil];
    organizeViewController.navigationItem.title = @"我的部门";
    [self.navigationController pushViewController:organizeViewController animated:YES];
}

- (void)enterReportChartController
{
    UsersModel * owner = [[[EventsService alloc] init] getCurrentUser];
    if ([VerifyHelper isEmpty:owner.chartAuth]) {
        [self showAlertwithTitle:@"😭... 您无任何报表可以查看"];
        return;
    }
    DepartmentOnlyViewController *dovCtrl = [[DepartmentOnlyViewController alloc] initWithNibName:@"DepartmentOnlyViewController" bundle:nil];
    [self.navigationController pushViewController:dovCtrl animated:YES];
}

- (void)initHomeView
{
    [self initTipImageView];
//    [self initBeacon];
    
    if (CURRENT_VERSION < 7) {
        constraintTop.constant = 0;
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"首页";
    [btnSignOut setTitle:@"签退\n列表" forState:UIControlStateNormal];
    btnSignOut.titleLabel.numberOfLines = 0;
    btnSignOut.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [GraphicHelper convertRectangleToCircular:btnSignIn withBorderColor:rgbaColor(9, 245, 9, 1.f) andBorderWidth:1];
    [GraphicHelper convertRectangleToCircular:btnSignOut withBorderColor:rgbaColor(231, 37, 32, 1.f) andBorderWidth:1];
    [GraphicHelper convertRectangleToCircular:bgSignInLabel withBorderColor:rgbaColor(9, 245, 9, 1.f) andBorderWidth:2];
    [GraphicHelper convertRectangleToCircular:bgSignOutLabel withBorderColor:rgbaColor(231, 37, 32, 1.f) andBorderWidth:2];
    bgSignOutLabel.hidden = YES;
    
    EventsService *service = [[EventsService alloc] init];
    UsersModel *model = [service getCurrentUser];
    if ([model.needSignIn isEqualToNumber:@1]) {
        [self sendRequestVerifyAttendance];
    }
    else
    {
        [self saveLoginUserSignStatus:@0 WithSignType:SignType_In];
        [self saveLoginUserSignStatus:@0 WithSignType:SignType_Out];
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:TIMER_AWEAK_INTERVAL target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}

- (void)initTipImageView
{
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tipClick:)];
    [tipImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void) firstStartAppShowTip
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"isShowTip"]) {
        [self tipImageViewShowAnn];
        [defaults setObject:@"1" forKey:@"isShowTip"];
        [defaults synchronize];
    }
}


#pragma mark -
#pragma mark 界面逻辑处理
- (void)changeSignInButtonColorWithSignInImageStatus:(BOOL)isShow
{
    if (isShow) {  //当已签到
        bgSignInLabel.hidden = YES;
    }
    else  //当未签到
    {
        bgSignInLabel.hidden = NO;
    }
}

- (void)changeSignOutButtonColorWithSignOutImageStatus:(BOOL)isShow
{
    if (isShow) {
        bgSignOutLabel.hidden = YES;
    }
    else
    {
        bgSignOutLabel.hidden = NO;
    }
}


- (void)getCurrentTime
{
    NSDateComponents *comps = [TimeHelper getDateComponents];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *workEndTime = [defaults objectForKey:@"workEndTime"];
    NSDate *work_date = [dateFormatter dateFromString:workEndTime];
    NSDateComponents *workComps = [TimeHelper getDateComponentsWithDate:work_date];
    if (comps.hour >= workComps.hour) {
        if (signOutAttendanceImageView.hidden == YES) {
            EventsService *service = [[EventsService alloc] init];
            UsersModel *model = [service getCurrentUser];
            if ([model.needSignIn isEqualToNumber:@1]) {
                [self changeSignOutButtonColorWithSignOutImageStatus:NO];
            }
        }
        else
        {
            [self changeSignOutButtonColorWithSignOutImageStatus:YES];
        }
    }
}

- (void) genieToRect: (CGRect)rect edge: (BCRectEdge) edge
{
    NSTimeInterval duration = 0.5;
    
    CGRect endRect = CGRectInset(rect, 0.1, 0.1);
    if (tipImageShow) {
        [tipImageView genieOutTransitionWithDuration:duration startRect:endRect startEdge:edge completion:^{        }];
    } else {
        [tipImageView genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:edge completion:^{
            tipImageView.hidden = YES;
        }];
    }
}


- (void)tipImageViewShowAnn
{
    [tipImageView removeFromSuperview];
    [self.view addSubview:tipImageView];
    if (CURRENT_VERSION>=8) {
        NSLayoutConstraint *layoutCenter = [NSLayoutConstraint constraintWithItem:tipImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:topBgView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:108.f];
        [self.view addConstraint:layoutCenter];
        
        NSLayoutConstraint *layoutleft = [NSLayoutConstraint constraintWithItem:tipImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:11.f];
        [self.view addConstraint:layoutleft];
        
    }
    tipImageView.hidden = NO;
    tipImageShow = YES;
    
    float AnnY = 84;
    if (CURRENT_VERSION<7) {
        AnnY = 20;
    }
    CGRect rect = CGRectMake(288, AnnY, 16, 5);
    [self genieToRect:rect edge:BCRectEdgeBottom];
}

- (void)tipImageViewCloseAnn
{
    tipImageShow = NO;
    float AnnY = 84;
    if (CURRENT_VERSION<7) {
        AnnY = 20;
    }
    CGRect rect = CGRectMake(288, AnnY, 16, 16);
    [self genieToRect:rect edge:BCRectEdgeBottom];
}

-(void)showCurrentDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    
    dateFormatter.dateFormat = @"dd";
    lblDay.text = [dateFormatter stringFromDate:date];
    
    dateFormatter.dateFormat = @"EEEE";
    lblWeek.text = [dateFormatter stringFromDate:date];
    
    dateFormatter.dateFormat = @"yyyy年MM月";
    lblYearAndMonth.text = [dateFormatter stringFromDate:date];
}

- (void)showSignStatus
{
    EventsService *service = [[EventsService alloc] init];
    UsersModel *model = [service getCurrentUser];
    if ([[self getLoginUserSignStatusWithType:SignType_In] isEqualToNumber:@1]) {
        signInAttendanceImageView.hidden = NO;
        [self changeSignInButtonColorWithSignInImageStatus:YES];
        [btnSignIn setTitle:@"外访\n签到" forState:UIControlStateNormal];
        btnSignIn.titleLabel.numberOfLines = 0;
        btnSignIn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else
    {
        signInAttendanceImageView.hidden = YES;
        [self changeSignInButtonColorWithSignInImageStatus:NO];
        if ([model.needSignIn isEqual:@1]) {
            [btnSignIn setTitle:@"考勤\n签到" forState:UIControlStateNormal];
            btnSignIn.titleLabel.numberOfLines = 0;
            btnSignIn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        else
        {
            [btnSignIn setTitle:@"外访\n签到" forState:UIControlStateNormal];
            btnSignIn.titleLabel.numberOfLines = 0;
            btnSignIn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
    }
    
    if ([[self getLoginUserSignStatusWithType:SignType_Out] isEqualToNumber:@1]) {
        signOutAttendanceImageView.hidden = NO;
        [self changeSignOutButtonColorWithSignOutImageStatus:YES];
    }
    else
    {
        signOutAttendanceImageView.hidden = YES;
    }
}

- (void)sendRequestVerifyAttendance
{
    NSLog(@"检查是否已经签到");
    EventsService *service = [[EventsService alloc] init];
    [service verifyHasAttendanceSignIn];
}

- (void)sendRequestVerifyIfNeedAttendanceSignIn
{
    //检查是否需要考勤签到的请求
    EventsService *service = [[EventsService alloc] init];
    UsersModel *model = [service getCurrentUser];
    if ([model.needSignIn isEqualToNumber:@1]) {
        [self sendRequestVerifyAttendance];
    }
    else
    {
        [self pushSignContentViewControllerWithMainFoundation:MAINFOUNDATION_SING_IN];
    }
}

- (void)verifyAttendanceSignInComplete:(NSNotification *)notification
{
    // 0 : 都没签  1:签到 2:签退
    NSDictionary *infoDict = [self doResponse:notification.userInfo];
    if (infoDict) {
        if (![infoDict[@"signStatus"] isEqualToString:@"0"]) { //如果已经考勤签到
            signInAttendanceImageView.hidden = NO;
            [self changeSignInButtonColorWithSignInImageStatus:YES];
            [btnSignIn setTitle:@"外访\n签到" forState:UIControlStateNormal];
            if ([infoDict[@"signStatus"] isEqualToString:@"1"]) {
                [self saveLoginUserSignStatus:@1 WithSignType:SignType_In];
                [self saveLoginUserSignStatus:@0 WithSignType:SignType_Out];
            }
            else if ([infoDict[@"signStatus"] isEqualToString:@"2"])
            {
                [self saveLoginUserSignStatus:@1 WithSignType:SignType_In];
                [self saveLoginUserSignStatus:@1 WithSignType:SignType_Out];
            }
            if (signButtonClick) {
                [self pushSignContentViewControllerWithMainFoundation:MAINFOUNDATION_SING_IN];
            }
        }
        else //如果还未考勤签到
        {
            [self saveLoginUserSignStatus:@0 WithSignType:SignType_In];
            [self saveLoginUserSignStatus:@0 WithSignType:SignType_Out];
            [self showSignStatus];
            if (signButtonClick) {
                [self pushSignContentViewControllerWithMainFoundation:MAINFOUNDATION_ATTENDANCE_SIGN_IN];
            }
        }
    }
}

- (void)pushSignContentViewControllerWithMainFoundation:(MAINFOUNDATION)foundation
{
    SignContentViewController *signContentCtrl = [[SignContentViewController alloc] initWithNibName:@"SignContentViewController" bundle:nil];
    signContentCtrl.mainFoundation = foundation;
    signContentCtrl.vaildAttendanceSignIn = validForSignIn;
    [self.navigationController pushViewController:signContentCtrl animated:YES];
}
#pragma mark -
#pragma mark 界面事件处理

- (IBAction)smartReportInterface:(id)sender
{
    UsersModel * owner = [[[EventsService alloc] init] getCurrentUser];
    NSArray *tempAry = [[[CDDepartmentDAO alloc] init] findByOwnerEmail:owner.email];
    if ((!tempAry) || ([tempAry count] == 0)) {
        [self enterReportChartController];
    }
    else
    {
        [self enterOrganizerController];
    }
}

- (IBAction)helpButtonClick:(id)sender
{
    NSLog(@"help");
    if (tipImageView.hidden) {
        [self tipImageViewShowAnn];
    }else{
        [self tipImageViewCloseAnn];
    }
}

-(IBAction)btnSignInClick:(id)sender
{
    signButtonClick = YES;
    [self sendRequestVerifyIfNeedAttendanceSignIn];
}

-(IBAction)btnSignOutClick:(id)sender
{
    UsersModel * owner = [[[EventsService alloc] init] getCurrentUser];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString * stringDate = [dateFormatter stringFromDate:date];
    SubSignDetailViewController *signDetailViewController = [[SubSignDetailViewController alloc] initWithNibName:@"SubSignDetailViewController" bundle:nil];
    signDetailViewController.showDate = stringDate;
    NSMutableArray *tempUserAry = [[[CDUserDAO alloc] init] findBySuperOwnerEmail:owner.email];
    for (int i =0; i<[tempUserAry count]; i++) {
        CDUser *tempUser = tempUserAry[i];
        if ([tempUser.email isEqualToString:owner.email]) {
            [tempUserAry removeObject:tempUser];
        }
    }
    [tempUserAry insertObject:[[[CDUserDAO alloc] init] findById:owner.userId] atIndex:0];
    signDetailViewController.personAryArray = tempUserAry;
    
    signDetailViewController.dateAry = [self getCurrentDateArrayEndWithToday];
    [self.navigationController pushViewController:signDetailViewController animated:YES];
}

//helper
- (NSArray *)getCurrentDateArrayEndWithToday
{
    NSDate *today = [NSDate date];
    NSMutableArray *dateAry = [@[] mutableCopy];
    NSDateComponents *comps = [TimeHelper getDateComponentsWithDate:today];
    int day = (int)comps.day;
    for (int i =day; i>0; i--) {
        NSString *dateStr = [NSString stringWithFormat:@"%.2ld-%.2d-%.2d",(long)comps.year,comps.month,i];
        [dateAry addObject:dateStr];
    }
    return dateAry;
}

-(IBAction)btnEventBoxClick:(id)sender
{
    EventsBoxViewController *eventsBoxViewController = [[EventsBoxViewController alloc] initWithNibName:@"EventsBoxViewController" bundle:nil];
    eventsBoxViewController.currentBox = Box_owner;
    [self.navigationController pushViewController:eventsBoxViewController animated:YES];
}

-(IBAction)btnSettingClick:(id)sender
{
    SettingViewController *setViewCtrl = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:setViewCtrl animated:YES];
}

- (IBAction)btnMyProfileClick:(id)sender
{
    MyProfileViewController *myProfile = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    [self.navigationController pushViewController:myProfile animated:YES];
}

-(void)tipClick:(UIGestureRecognizer*)recognizer
{
    [self tipImageViewCloseAnn];
}

#pragma mark -代理处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        signButtonClick = YES;
        [self sendRequestVerifyIfNeedAttendanceSignIn];
    }
}

#pragma mark - beacon initialized
//- (void)initBeacon
//{
//    self.beacons = [[NSMutableDictionary alloc] init];
//    
//    // This location manager will be used to demonstrate how to range beacons.
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    
//    // Populate the regions we will range once.
//    self.rangedRegions = [[NSMutableDictionary alloc] init];
//    
//    for (NSUUID *uuid in [APLDefaults sharedDefaults].supportedProximityUUIDs)
//    {
//        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
//        self.rangedRegions[region] = [NSArray array];
//    }
//}
//
//- (void)startLocationWithBeacon
//{
//    for (CLBeaconRegion *region in self.rangedRegions)
//    {
//        [self.locationManager startRangingBeaconsInRegion:region];
//    }
//}
//
//- (void)stopLocationWithBeacon
//{
//    for (CLBeaconRegion *region in self.rangedRegions)
//    {
//        [self.locationManager stopRangingBeaconsInRegion:region];
//    }
//}

//beacon delegate

//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//{
//    /*
//     CoreLocation will call this delegate method at 1 Hz with updated range information.
//     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
//     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
//     use a set instead of an array.
//     */
//    self.rangedRegions[region] = beacons;
//    [self.beacons removeAllObjects];
//    
//    NSMutableArray *allBeacons = [NSMutableArray array];
//    
//    for (NSArray *regionResult in [self.rangedRegions allValues])
//    {
//        [allBeacons addObjectsFromArray:regionResult];
//    }
//    
//    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
//    {
//        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
//        if([proximityBeacons count])
//        {
//            self.beacons[range] = proximityBeacons;
//        }
//    }
////    [self checkBeaconData];
//}

//-(void)checkBeaconData
//{
//    for (int i=0; i<[[self.beacons allKeys] count]; i++) {
//        NSNumber *sectionKey = [self.beacons allKeys][i];
//        CLBeacon *beacon = [self.beacons[sectionKey] lastObject];
//        if (beacon&&[beacon.proximityUUID.UUIDString isEqualToString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]) {
//            validForSignIn = YES;
//            [self stopLocationWithBeacon];
//        }
//    }
//}

#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyAttendanceSignInComplete:) name:VERIFY_ATTENDANCE_SIGN_IN_NOTIFICATION object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VERIFY_ATTENDANCE_SIGN_IN_NOTIFICATION object:nil];
}
@end