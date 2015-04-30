//
//  SignDetailViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SignDetailViewController.h"
#import "SignDetailCell.h"
#import "EventModel.h"
#import "EventsService.h"
#import "TimeHelper.h"
#import "SignContentViewController.h"
#import "ImageShowViewController.h"
#import "OSTImageView.h"
#import "MapViewController.h"
#import "OSTMapInfo.h"
#import "SignDetailHeader.h"
#import "MJRefresh.h"
#import "CDEvent.h"
#import "CDEventDAO.h"

static BOOL isRefreshIng = NO;
static int lowerPage = 0;
static int upperPage = 0;

static BOOL isEditEvent = NO;
@interface SignDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet NSLayoutConstraint *constraintTop;
    MJRefreshHeaderView *refreshHeader;
    MJRefreshFooterView *refreshFooter;
    SignContentViewController *markSignOutCtrl;
    NSString *refreshDate;
    NSMutableArray *showDateArray;
    NSMutableDictionary *dataSourceDict;
    int showDateCount;
    
     BOOL needUpdate;
}
@end

@implementation SignDetailViewController
@synthesize showDate,currentUser,eventMethod,dateArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        needUpdate = NO;
    }
    return self;
}

#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSignDetailViewController];
    refreshDate = self.showDate;
    if (dataSourceDict) {
        dataSourceDict = nil;
    }
    [self sendRequestGetFiveMoreInfomation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
    [self registMapImageSelectNotification];
    if (isEditEvent) {
        needUpdate = YES;
        [self sendRequestGetNewSignDetailDataWithDate:refreshDate];
        isEditEvent = NO;
    }
    [mainTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self freeMapImageSelectedNotification];
    [self freeNotification];
}

- (void)dealloc
{
    [self freeNotification];
    [self refreshCtrlFree];
}
#pragma mark -
#pragma mark 界面事件处理

- (void)checkButtonClick
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"外访"]) {
        self.navigationItem.rightBarButtonItem.title = @"考勤";
        self.eventMethod = SHOWEVENT_VISIT;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"外访";
        self.eventMethod = SHOWEVENT_ATTENDANCE;
    }
    [showDateArray removeAllObjects];
    [showDateArray addObject:self.showDate];
    lowerPage = showDateCount;
    upperPage = showDateCount;
    refreshDate = self.showDate;
    dataSourceDict = nil;
    [self sendRequestGetFiveMoreInfomation];
}

- (void)editButtonClick:(OSTButton *)sender
{
    EventsService *eventService = [[EventsService alloc] init];
    UsersModel *owner = [eventService getCurrentUser];
    if (self.currentUser.userId&&![self.currentUser.userId isEqualToString:owner.userId]) {
        [self showAlertwithTitle:@"您不能更改他人的备注信息"];
        return;
    }
    SignContentViewController *signContentCtrl = [[SignContentViewController alloc] initWithNibName:@"SignContentViewController" bundle:nil];
    EventModel *eventModel =  sender.event;
    signContentCtrl.mainFoundation = MAINFOUNDATION_EDIT;
    signContentCtrl.currentEventModel = eventModel;
    signContentCtrl.signedIncoordinate = CLLocationCoordinate2DMake(eventModel.signIn.latitude, eventModel.signIn.longitude);
    isEditEvent = YES;
    refreshDate = [TimeHelper getYearMonthDayWithDate:[TimeHelper convertSecondsToDate:eventModel.createTime]];
    refreshDate = sender.btnId;
    [self.navigationController pushViewController:signContentCtrl animated:YES];

}

- (void)signOutButtonClick:(OSTButton *)sender
{
    EventsService *eventService = [[EventsService alloc] init];
    UsersModel *owner = [eventService getCurrentUser];
    if (self.currentUser.userId&&![self.currentUser.userId isEqualToString:owner.userId]) {
        [self showAlertwithTitle:@"您不能替他人签退"];
        return;
    }
    SignContentViewController *signContentCtrl = [[SignContentViewController alloc] initWithNibName:@"SignContentViewController" bundle:nil];
    EventModel *eventModel = sender.event;
    NSDateComponents *comps = [TimeHelper convertTimeToDateComponents:eventModel.createTime];
    if (![self checkVaildDayToSignout:comps.day]) {
        [self showAlertwithTitle:@"😓～～ 该事件已过期，您现在不能签退!"];
        return;
    }
    signContentCtrl.currentEventModel = eventModel;
    signContentCtrl.signedIncoordinate = CLLocationCoordinate2DMake(eventModel.signIn.latitude, eventModel.signIn.longitude);
    signContentCtrl.mainFoundation = [eventModel.eventType.modelId isEqualToString:@"1"]?MAINFOUNDATION_ATTENDANCE_SIGN_OUT:MAINFOUNDATION_SING_OUT;
    markSignOutCtrl = signContentCtrl;
    if ((![self canAttenDanceSignOut])&&(signContentCtrl.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_OUT)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"还未下班，您确定要考勤签退？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        refreshDate = [TimeHelper getYearMonthDayWithDate:[TimeHelper convertSecondsToDate:eventModel.createTime]];
        [alert show];
    }
    else
    {
        isEditEvent = YES;
        refreshDate = [TimeHelper getYearMonthDayWithDate:[TimeHelper convertSecondsToDate:eventModel.createTime]];
        refreshDate = sender.btnId;
        [self.navigationController pushViewController:signContentCtrl animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        isEditEvent = YES;
        [self.navigationController pushViewController:markSignOutCtrl animated:YES];
    }
}
#pragma mark -
#pragma mark 界面逻辑处理
- (void)sendRequestGetFiveMoreInfomation
{
    FindType type;
    switch (self.eventMethod) {
        case SHOWEVENT_ALL:
            type = FindType_All;
            break;
        case SHOWEVENT_ATTENDANCE:
            type = FindType_Attendance;
            break;
        case SHOWEVENT_VISIT:
            type = FindType_Visit;
            break;
        default:
            break;
    }
    
    UsersModel *tempModel = self.currentUser?self.currentUser:[[[EventsService alloc] init] getCurrentUser];
    NSArray *tempEventAry = [CDEventDAO findByOwinerId:tempModel.userId andDateStr:self.showDate andSearchType:type];
    if (!tempEventAry || tempEventAry.count == 0) {
        [self sendRequestGetNewSignDetailDataWithDate:self.showDate];
        [self addFooter];
        return;
    }
    
    NSMutableArray *tempAry = [@[] mutableCopy];
    if (self.dateArray.count>5) {
        for (int i=0; i<5; i++) {
            [tempAry addObject:self.dateArray[i]];
        }
    }
    else
    {
        tempAry = [self.dateArray mutableCopy];
    }
    
    NSDictionary *eventDic = [CDEventDAO findByOwinerId:tempModel.userId andDateAry:tempAry andSearchType:type];
    int num = 0;
    for (int i = 0; i<eventDic.count; i++) {
        NSArray *temp = eventDic[eventDic.allKeys[i]];
        if (!temp || temp.count == 0) {
            num ++;
        }
    }
    if (num>2) {
        [self sendRequestGetNewSignDetailDataWithDate:self.showDate];
        [self addFooter];
        return;
    }
    lowerPage = 0;
    upperPage = tempAry.count-1;
    showDateArray = [NSMutableArray arrayWithArray:tempAry];
    [self addFooter];
    
    [self readEventDataFromCoreDataWithDateAry:tempAry userModel:tempModel andSearchType:type];
}

- (void)readEventDataFromCoreDataWithDateAry:(NSArray *)ary userModel:(UsersModel *)aModel andSearchType:(FindType)type
{
    NSDictionary *eventDic = [CDEventDAO findByOwinerId:aModel.userId andDateAry:ary andSearchType:type];
    if (!eventDic) {
        return;
    }
    if (!dataSourceDict) {
        dataSourceDict = [eventDic mutableCopy];
    }
    else
    {
        [dataSourceDict addEntriesFromDictionary:eventDic];
    }
    [self performSelector:@selector(endFreshFooter) withObject:self afterDelay:0.2];
    [mainTableView reloadData];
}


- (BOOL)canAttenDanceSignOut
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
        return YES;
    }
    else
        return NO;
}

- (void)sendRequestGetNewSignDetailDataWithDate:(NSString *)dateStr
{
    EventsService *eventeService = [[EventsService alloc] init];
    refreshDate = dateStr;
    switch (self.eventMethod) {
        case SHOWEVENT_ALL:
            {
                if (!needUpdate) {
                    [self readEventDataFromCoreDataWithDate:dateStr userModel:self.currentUser andSearchType:SearchType_All];
                    return;
                }
                [eventeService findSomedayOwnSignEvents:dateStr andUser:self.currentUser andSearchType:SearchType_All];
            }
            break;
        case SHOWEVENT_ATTENDANCE:
            {
                if (!needUpdate) {
                    [self readEventDataFromCoreDataWithDate:dateStr userModel:self.currentUser andSearchType:SearchType_Attendance];
                    return;
                }
                [eventeService findSomedayOwnSignEvents:dateStr andUser:self.currentUser andSearchType:SearchType_Attendance];
            }
            break;
        case SHOWEVENT_VISIT:
            {
                if (!needUpdate) {
                    [self readEventDataFromCoreDataWithDate:dateStr userModel:self.currentUser andSearchType:SearchType_Visit];
                    return;
                }
                [eventeService findSomedayOwnSignEvents:dateStr andUser:self.currentUser andSearchType:SearchType_Visit];
            }
            break;
    }
}

- (void)readEventDataFromCoreDataWithDate:(NSString *)dateStr userModel:(UsersModel *)aModel andSearchType:(SearchType)type
{
    FindType tempType;
    switch (type) {
        case SearchType_All:
            tempType = FindType_All;
            break;
        case SearchType_Attendance:
            tempType = FindType_Attendance;
            break;
        case SearchType_Visit:
            tempType = FindType_Visit;
            break;
        default:
            break;
    }
    NSArray *eventAry = [CDEventDAO findByOwinerId:aModel.userId andDateStr:dateStr andSearchType:tempType];
    if (!eventAry || eventAry.count == 0) {
        EventsService *eventeService = [[EventsService alloc] init];
        needUpdate = YES;
        [eventeService findSomedayOwnSignEvents:dateStr andUser:aModel andSearchType:type];
        return;
    }
    
    NSMutableArray *mutAry = [@[] mutableCopy];
    [eventAry enumerateObjectsUsingBlock:^(CDEvent *obj, NSUInteger idx, BOOL *stop) {
        EventModel *tempModel = [obj toEventModel];
        [mutAry addObject:tempModel];
    }];
    NSNotification *notif = [NSNotification notificationWithName:@"" object:nil userInfo:@{@"resultCode":@"I00101",@"resultData":mutAry}];
    [self findSomeDayOwnSignEventComplete:notif];
}

- (BOOL)checkVaildDayToSignout:(NSInteger)dayValue
{
    NSDateComponents *comps = [TimeHelper getDateComponents];
    if (dayValue == comps.day) {
        return YES;
    }
    return NO;
}


- (void)showImageOnOtherController:(NSNotification *)notification
{
    OSTImageView *currentImageView = notification.userInfo[@"obj"];
    if (currentImageView.image) {
        ImageShowViewController *imageShowController = [[ImageShowViewController alloc] initWithNibName:@"ImageShowViewController" bundle:nil];
        imageShowController.deletButtonHidden = YES;
        imageShowController.screenimage = currentImageView.image;
        [self.navigationController pushViewController:imageShowController animated:YES];
    }
}

- (void)showMapImageOnMapView:(NSNotification *)notification
{
    [self freeMapImageSelectedNotification];
    OSTImageView *currentImageView = notification.userInfo[@"obj"];
    OSTMapInfo *info = currentImageView.mapInfoAry[0];
    NSLog(@"%f",info.pinAnnotation.annotation.coordinate.latitude);
    MapViewController *mapCtrl = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapCtrl.pointViewAry = currentImageView.mapInfoAry;
    [self.navigationController pushViewController:mapCtrl animated:YES];
}

#pragma mark -
#pragma mark  代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (showDateArray) {
        return [showDateArray count];
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SignDetailHeader *header = [SignDetailHeader loadFromNib];
    header.timeLabel.text = showDateArray[section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignDetailCell *cell = (SignDetailCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGFloat height = [cell.ostContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height+5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dataSourceDict) {
        NSString *timeStr = showDateArray[section];
        NSArray *source = dataSourceDict[timeStr];
        if (source) {
            return [source count];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *timeStr = showDateArray[indexPath.section];
    EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
    SignDetailCell *cell = nil;
    UsersModel *owner = [[[EventsService alloc] init] getCurrentUser];
    self.navigationItem.title = [NSString stringWithFormat:@"%@的事件",[owner.username isEqualToString:eventModel.creator]?@"我":eventModel.creator];
    //考勤签到
    if ([eventModel.eventType.modelId isEqualToString:@"1"]) {
        if (eventModel.status == 2) {
            //已签退
            cell = [self initializeAttenDanceHasSignOutCell:tableView indexPath:indexPath];
        }
        else //未签退
        {
            cell = [self initializeAttenDanceNoSignOutCell:tableView indexPath:indexPath];
        }
    }
    else  //外出拜访
    {
        if (eventModel.status == 2) {
            //已签退
            cell = [self initializeVisitHasSignOutCell:tableView indexPath:indexPath];
        }
        else //未签退
        {
            cell = [self initializeVisitNoSignOutCell:tableView indexPath:indexPath];
        }
    }
    
    OSTMapInfo *info_in = [[OSTMapInfo alloc] init];
    info_in.address = eventModel.signIn.location;
    MKPointAnnotation *ann_in = [[MKPointAnnotation alloc] init];
    ann_in.coordinate = CLLocationCoordinate2DMake(eventModel.signIn.latitude, eventModel.signIn.longitude);
    MKPinAnnotationView *temp_in = [[MKPinAnnotationView alloc] initWithAnnotation:ann_in reuseIdentifier:nil];
    temp_in.pinColor = MKPinAnnotationColorGreen;
    info_in.pinAnnotation = temp_in;
    cell.mapImageView.mapInfoAry = @[info_in];
    
    if (eventModel.signOut.location.length>0) {
        OSTMapInfo *info_out = [[OSTMapInfo alloc] init];
        info_out.address = eventModel.signOut.location;
        MKPointAnnotation *ann_out = [[MKPointAnnotation alloc] init];
        ann_out.coordinate = CLLocationCoordinate2DMake(eventModel.signOut.latitude, eventModel.signOut.longitude);
        MKPinAnnotationView *temp_out = [[MKPinAnnotationView alloc] initWithAnnotation:ann_out reuseIdentifier:nil];
        temp_out.pinColor = MKPinAnnotationColorRed;
        info_out.pinAnnotation = temp_out;
        NSArray *s_out = @[info_in,info_out];
        cell.mapImageView.mapInfoAry = s_out;
    }
    
    NSDateComponents *comps = [TimeHelper convertTimeToDateComponents:eventModel.createTime];
    if (![self checkVaildDayToSignout:comps.day]) {
        [cell.signOutButton setBackgroundColor:[UIColor lightGrayColor]];
        cell.signOutButton.userInteractionEnabled = NO;
    }
    
    [cell.signOutButton addTarget:self action:@selector(signOutButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.writeSummaryButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.signOutButton.event = eventModel;
    cell.editButton.event = eventModel;
    cell.signOutButton.btnId = timeStr;
    cell.editButton.btnId = timeStr;
    cell.writeSummaryButton.btnId = timeStr;
    cell.writeSummaryButton.event = eventModel;
    [cell setImageToImageView:cell.mapImageView withFilename:eventModel.signIn.pictureUrl];
    return cell;
}

- (SignDetailCell *)initializeAttenDanceNoSignOutCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SignDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [SignDetailCell loadAttendanceEventNoSignOutFromNib];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
    }
    NSString *timeStr = showDateArray[indexPath.section];
    EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
    [cell initAttendanceNoSignOutCellWithEventModel:eventModel];
    return cell;
}

- (SignDetailCell *)initializeAttenDanceHasSignOutCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SignDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [SignDetailCell loadAttendanceEventHasSignOutFromNib];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
    }
    NSString *timeStr = showDateArray[indexPath.section];
    EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
    [cell initAttendanceHasSignOutCellWithEventModel:eventModel];
    return cell;
}

- (SignDetailCell *)initializeVisitHasSignOutCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SignDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [SignDetailCell loadVisitEventHasSignOutFromNib];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
    }
    NSString *timeStr = showDateArray[indexPath.section];
    EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
    [cell initVisitHasSignOutCellWithEventModel:eventModel];
    return cell;
}

- (SignDetailCell *)initializeVisitNoSignOutCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SignDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [SignDetailCell loadVisitEventNoSignOutFromNib];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
    }
    NSString *timeStr = showDateArray[indexPath.section];
    EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
    [cell initVisitnoSignOutCellWithEventModel:eventModel];
    return cell;
}


#pragma mark -
#pragma mark 界面操作
- (void)initSignDetailViewController
{
    showDateArray = [NSMutableArray arrayWithObject:self.showDate];
    if (self.dateArray) {
        //排序从小到大
        for (int i=0; i<[self.dateArray count]; i++) {
            if ([self.dateArray[i] isEqualToString:self.showDate]) {
                showDateCount = i;
                lowerPage = showDateCount;
                upperPage = showDateCount;
            }
        }
    }
    switch (self.eventMethod) {
        case SHOWEVENT_ALL:
            {
            }
            break;
        case SHOWEVENT_ATTENDANCE:
            {
                [self addHeader];
                [self addFooter];
                UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"外访" style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
                self.navigationItem.rightBarButtonItem = rightItem;
            }
            break;
        case SHOWEVENT_VISIT:
            {
                [self addHeader];
                [self addFooter];
                UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"考勤" style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
                self.navigationItem.rightBarButtonItem = rightItem;
            }
            break;
        default:
            break;
    }
    
    if (CURRENT_VERSION < 7) {
        constraintTop.constant = 0;
    }
}

- (void)addHeader
{
    if (refreshHeader == nil) {
        refreshHeader = [MJRefreshHeaderView header];
        refreshHeader.scrollView = mainTableView;
        refreshHeader.lastUpdateTimeLabel.textColor = [UIColor whiteColor];
        refreshHeader.statusLabel.textColor = [UIColor whiteColor];
        __weak SignDetailViewController *block_self = self;
        __weak NSMutableArray *tempDateAry = showDateArray;
        __block BOOL needUD = needUpdate;
        refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            isRefreshIng = YES;
            needUD = YES;
            lowerPage--;
            if (lowerPage<0) {
                lowerPage = 0;
                [block_self toast:@"没有更早的信息啦"];
                [block_self performSelector:@selector(endFreshHeader) withObject:block_self afterDelay:0.05];
            }
            else
            {
                NSString *searchDate = block_self.dateArray[lowerPage];
                [tempDateAry insertObject:searchDate atIndex:0];
                [block_self sendRequestGetNewSignDetailDataWithDate:searchDate];
            }
        };
    }
}

- (void)addFooter
{
    if (refreshFooter) {
        [refreshFooter removeFromSuperview];
        refreshFooter = nil;
    }
    refreshFooter = [MJRefreshFooterView footer];
    refreshFooter.scrollView = mainTableView;
    refreshFooter.lastUpdateTimeLabel.textColor = [UIColor whiteColor];
    refreshFooter.statusLabel.textColor = [UIColor whiteColor];
    __weak SignDetailViewController *block_self = self;
    __weak NSMutableArray *tempDateAry = showDateArray;
    refreshFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //当开始加载更多时
        isRefreshIng = NO;
        upperPage++;
        if (upperPage<block_self.dateArray.count) {
            NSString * searchDate = block_self.dateArray[upperPage];
            [tempDateAry addObject:searchDate];
                [block_self sendRequestGetNewSignDetailDataWithDate:searchDate];
        }
        else
        {
            upperPage = block_self.dateArray.count-1;
            [block_self toast:@"没有更晚的信息啦"];
            [block_self performSelector:@selector(endFreshFooter) withObject:block_self afterDelay:0.05];
        }
    };
}

- (void)endFreshHeader
{
    if (refreshHeader) {
        [refreshHeader endRefreshingWithoutIdle];
    }
}

- (void)endFreshFooter
{
    if (refreshFooter) {
        [refreshFooter endRefreshingWithoutIdle];
    }
}

- (void)refreshCtrlFree
{
    [refreshFooter free];
    [refreshHeader free];
}
#pragma mark -
#pragma mark 回调处理

- (void)findSomeDayOwnSignEventComplete:(NSNotification *)notification
{
    NSDictionary * dic = notification.userInfo;
    if ([self doResponse:dic]) {
        if (!self.dateArray || self.dateArray.count == 0) {
            dataSourceDict = [@{self.showDate:dic[@"resultData"]} mutableCopy];
        }
        else
        {
            if (!dataSourceDict) {
                dataSourceDict = [@{refreshDate:dic[@"resultData"]} mutableCopy];
            }
            else
            {
                [dataSourceDict setObject:dic[@"resultData"] forKey:refreshDate];
            }
        }
    }
    needUpdate = NO;
    [self performSelector:@selector(endFreshFooter) withObject:self afterDelay:0.2];
    [self performSelector:@selector(endFreshHeader) withObject:self afterDelay:0.2];
    [mainTableView reloadData];
}


#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findSomeDayOwnSignEventComplete:) name:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImageOnOtherController:) name:OSTIMAGEVIEW_SHOWIMAGE_NOTIFICATION object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OSTIMAGEVIEW_SHOWIMAGE_NOTIFICATION object:nil];
}

- (void)registMapImageSelectNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMapImageOnMapView:) name:OSTIMAGEVIEW_PICKIMAGE_NOTIFICATION object:nil];
}

- (void)freeMapImageSelectedNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OSTIMAGEVIEW_PICKIMAGE_NOTIFICATION object:nil];
}
@end
