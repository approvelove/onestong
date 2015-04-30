//
//  SubSignDetailViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SubSignDetailViewController.h"
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
#import "CDUser.h"
#import "CDUserDAO.h"
#import "UsersModel.h"
#import "CDEvent.h"
#import "CDEventDAO.h"

static BOOL isRefreshIng = NO;
static int upperPage = 0;

static BOOL isEditEvent = NO;

typedef NS_ENUM(NSInteger, SEARCHTYPE) {
    SEARCHTYPE_TIME,
    SEARCHTYPE_PERSON
};

@interface SubSignDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet NSLayoutConstraint *constraintTop;
    MJRefreshFooterView *refreshFooter;
    SignContentViewController *markSignOutCtrl;
    UsersModel *refresPerson;
    
    //人－纬度
    NSMutableArray *showPersonArray;
    NSMutableDictionary *dataSourceDict;
    int showPersonCount;
    CDUser *CDOwner;
    
    //时间 - 纬度
    NSString *refreshDate;
    NSMutableArray *showDateArray;
    int showDateCount;
    SEARCHTYPE currentType;
    
    BOOL needUpdate;
}
@end

@implementation SubSignDetailViewController
@synthesize showDate,currentUser,personAryArray,dateAry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentType = SEARCHTYPE_TIME;
        needUpdate = NO;
    }
    return self;
}

#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    CDOwner = [self.personAryArray objectAtIndex:0];
    [self initSignDetailViewController];
    refresPerson = [CDOwner toUsersModel];
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
    switch (currentType) {
        case SEARCHTYPE_PERSON:
            {
                if (isEditEvent) {
                    needUpdate = YES;
                    [self sendRequestGetNewSignDetailDataWithUserModel:refresPerson andDateStr:nil];
                    isEditEvent = NO;
                }
            }
            break;
        case SEARCHTYPE_TIME:
            {
                if (isEditEvent) {
                    needUpdate = YES;
                    [self sendRequestGetNewSignDetailDataWithUserModel:nil andDateStr:refreshDate];
                    isEditEvent = NO;
                }
            }
            break;
        default:
            break;
    }
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
- (void)noticeButtonItemClick
{
    dataSourceDict = nil;
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"我的事件"]) {
        self.navigationItem.rightBarButtonItem.title = @"我的关注";
        self.navigationItem.title = @"我的事件";
        currentType = SEARCHTYPE_TIME;
        [self addFooter];
        upperPage = showDateCount;
        refreshDate = self.showDate;
        [showDateArray removeAllObjects];
        [showDateArray addObject:self.showDate];
        [self sendRequestGetNewSignDetailDataWithUserModel:nil andDateStr:refreshDate];
        [self sendRequestGetFiveMoreInfomation];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"我的事件";
        self.navigationItem.title = @"我的关注";
        currentType = SEARCHTYPE_PERSON;
        [self addFooter];
        upperPage = showPersonCount;
        refresPerson = [CDOwner toUsersModel];
        [showPersonArray removeAllObjects];
        [showPersonArray addObject:refresPerson.email];
        [self sendRequestGetNewSignDetailDataWithUserModel:refresPerson andDateStr:nil];
    }
}

- (void)editButtonClick:(OSTButton *)sender
{
    EventsService *eventService = [[EventsService alloc] init];
    EventModel *eventModel =  sender.event;
    
    UsersModel *owner = [eventService getCurrentUser];
    if (eventModel.publisher.modelId&&![eventModel.publisher.modelId isEqualToString:owner.userId]) {
        [self showAlertwithTitle:@"您不能更改他人的备注信息"];
        return;
    }
    SignContentViewController *signContentCtrl = [[SignContentViewController alloc] initWithNibName:@"SignContentViewController" bundle:nil];
    signContentCtrl.mainFoundation = MAINFOUNDATION_EDIT;
    signContentCtrl.currentEventModel = eventModel;
    signContentCtrl.signedIncoordinate = CLLocationCoordinate2DMake(eventModel.signIn.latitude, eventModel.signIn.longitude);
    isEditEvent = YES;
    refreshDate = [TimeHelper getYearMonthDayWithDate:[TimeHelper convertSecondsToDate:eventModel.createTime]];
    refresPerson = [[[[CDUserDAO alloc] init] findByEmail:sender.btnId] toUsersModel];
    [self.navigationController pushViewController:signContentCtrl animated:YES];
}

- (void)signOutButtonClick:(OSTButton *)sender
{
    EventsService *eventService = [[EventsService alloc] init];
    EventModel *eventModel = sender.event;
    
    UsersModel *owner = [eventService getCurrentUser];
    if (eventModel.publisher.modelId&&![eventModel.publisher.modelId isEqualToString:owner.userId]) {
        [self showAlertwithTitle:@"您不能替他人签退"];
        return;
    }
    SignContentViewController *signContentCtrl = [[SignContentViewController alloc] initWithNibName:@"SignContentViewController" bundle:nil];
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
        refresPerson = [[[[CDUserDAO alloc] init] findByEmail:sender.btnId] toUsersModel];
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
    UsersModel *tempModel = [CDOwner toUsersModel];
    
    NSString *firstDate = self.dateAry[0];
    NSArray *tempEventAry = [CDEventDAO findByOwinerId:tempModel.userId andDateStr:firstDate andSearchType:FindType_All];
    if (!tempEventAry || tempEventAry.count == 0) {
        [self sendRequestGetNewSignDetailDataWithUserModel:tempModel andDateStr:firstDate];
        [self addFooter];
        return;
    }
    
    NSMutableArray *tempAry = [@[] mutableCopy];
    if (self.dateAry.count>5) {
        for (int i=0; i<5; i++) {
            [tempAry addObject:self.dateAry[i]];
        }
    }
    else
    {
        tempAry = [self.dateAry mutableCopy];
    }
    NSDictionary *eventDic = [CDEventDAO findByOwinerId:tempModel.userId andDateAry:tempAry andSearchType:FindType_All];
    int num = 0;
    for (int i = 0; i<eventDic.count; i++) {
        NSArray *temp = eventDic[eventDic.allKeys[i]];
        if (!temp || temp.count == 0) {
            num ++;
        }
    }
    if (num>2) {
        [self sendRequestGetNewSignDetailDataWithUserModel:tempModel andDateStr:firstDate];
        [self addFooter];
        return;
    }
    
    upperPage = tempAry.count-1;
    showDateArray = [NSMutableArray arrayWithArray:tempAry];
    [self addFooter];
    [self readEventDataFromCoreDataWithDateAry:tempAry userModel:[CDOwner toUsersModel] andSearchType:SearchType_All];
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

- (void)sendRequestGetNewSignDetailDataWithUserModel:(UsersModel *)aModel andDateStr:(NSString *)dateStr
{
    EventsService *eventeService = [[EventsService alloc] init];
    switch (currentType) {
        case SEARCHTYPE_PERSON:
            {
                refresPerson = aModel;
                if (!needUpdate) {
                    [self readEventDataFromCoreDataWithDate:self.showDate userModel:aModel andSearchType:SearchType_All];
                    return;
                }
                [eventeService findSomedayOwnSignEvents:self.showDate andUser:aModel andSearchType:SearchType_All];
            }
            break;
        case SEARCHTYPE_TIME:
            {
                refreshDate = dateStr;
                if (!needUpdate) {
                    [self readEventDataFromCoreDataWithDate:dateStr userModel:[CDOwner toUsersModel] andSearchType:SearchType_All];
                    return;
                }
                [eventeService findSomedayOwnSignEvents:dateStr andUser:self.currentUser andSearchType:SearchType_All];
            }
            break;
    }
}

- (void)readEventDataFromCoreDataWithDateAry:(NSArray *)ary userModel:(UsersModel *)aModel andSearchType:(SearchType)type
{
    NSDictionary *eventDic = [CDEventDAO findByOwinerId:aModel.userId andDateAry:ary andSearchType:FindType_All];
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

- (void)showDataInCDWithAry:(NSArray *)ary
{
    NSMutableArray *mutAry = [@[] mutableCopy];
    [ary enumerateObjectsUsingBlock:^(CDEvent *obj, NSUInteger idx, BOOL *stop) {
        EventModel *tempModel = [obj toEventModel];
        [mutAry addObject:tempModel];
    }];
    NSNotification *notif = [NSNotification notificationWithName:@"" object:nil userInfo:@{@"resultCode":@"I00101",@"resultData":mutAry}];
    [self findSomeDayOwnSignEventComplete:notif];
}

- (void)readEventDataFromCoreDataWithDate:(NSString *)dateStr userModel:(UsersModel *)aModel andSearchType:(SearchType)type
{
    NSArray *eventAry = [CDEventDAO findByOwinerId:aModel.userId andDateStr:dateStr andSearchType:FindType_All];
    if (!eventAry || eventAry.count ==0) {
        EventsService *eventeService = [[EventsService alloc] init];
        needUpdate = YES;
        [eventeService findSomedayOwnSignEvents:dateStr andUser:aModel andSearchType:SearchType_All];
        return;
    }
    [self showDataInCDWithAry:eventAry];
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
    switch (currentType) {
        case SEARCHTYPE_TIME:
            {
                if (showDateArray) {
                    return [showDateArray count];
                }
            }
            break;
        case SEARCHTYPE_PERSON:
            {
                if (showPersonArray) {
                    return [showPersonArray count];
                }
            }
            break;
        default:
            break;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (currentType) {
        case SEARCHTYPE_PERSON:
            {
                SignDetailHeader *header = [SignDetailHeader loadFromNib];
                //showPersonAry 存储用户的Email
                NSString *emailStr = showPersonArray[section];
                CDUser *tempUser = [[[CDUserDAO alloc] init] findByEmail:emailStr];
                header.timeLabel.text = tempUser.username;
                return header;
            }
            break;
        case SEARCHTYPE_TIME:
            {
                SignDetailHeader *header = [SignDetailHeader loadFromNib];
                header.timeLabel.text = showDateArray[section];
                return header;
            }
            break;
        default:
            break;
    }
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
    switch (currentType) {
        case SEARCHTYPE_TIME:
            {
                if (dataSourceDict) {
                    NSString *timeStr = showDateArray[section];
                    NSArray *source = dataSourceDict[timeStr];
                    if (source) {
                        return [source count];
                    }
                }
            }
            break;
        case SEARCHTYPE_PERSON:
            {
                if (dataSourceDict) {
                    NSString *emailStr = showPersonArray[section];
                    NSArray *source = dataSourceDict[emailStr];
                    if (source) {
                        return [source count];
                    }
                }
            }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EventModel *eventModel;
    NSString *emailStr;
    NSString *timeStr;
    switch (currentType) {
        case SEARCHTYPE_PERSON:
            {
                emailStr = showPersonArray[indexPath.section];
                eventModel = dataSourceDict[emailStr][indexPath.row];
            }
            break;
        case SEARCHTYPE_TIME:
            {
                timeStr = showDateArray[indexPath.section];
                eventModel = dataSourceDict[timeStr][indexPath.row];
            }
            break;
        default:
            break;
    }
    SignDetailCell *cell = nil;
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
    cell.writeSummaryButton.event = eventModel;
    switch (currentType) {
        case SEARCHTYPE_TIME:
           {
               cell.signOutButton.btnId = timeStr;
               cell.editButton.btnId = timeStr;
               cell.writeSummaryButton.btnId = timeStr;
           }
            break;
        case SEARCHTYPE_PERSON:
           {
               cell.signOutButton.btnId = emailStr;
               cell.editButton.btnId = emailStr;
               cell.writeSummaryButton.btnId = emailStr;
           }
            break;
        default:
            break;
    }
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
    [cell initAttendanceNoSignOutCellWithEventModel:[self getModelWithIndexPath:indexPath]];
    return cell;
}

- (EventModel *)getModelWithIndexPath:(NSIndexPath *)indexPath
{
    switch (currentType) {
        case SEARCHTYPE_PERSON:
           {
               NSString *emailStr = showPersonArray[indexPath.section];
               EventModel *eventModel = dataSourceDict[emailStr][indexPath.row];
               return eventModel;
           }
            break;
        case SEARCHTYPE_TIME:
          {
              NSString *timeStr = showDateArray[indexPath.section];
              EventModel *eventModel = dataSourceDict[timeStr][indexPath.row];
              return eventModel;
          }
            break;
        default:
            return nil;
            break;
    }
}

- (SignDetailCell *)initializeAttenDanceHasSignOutCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SignDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [SignDetailCell loadAttendanceEventHasSignOutFromNib];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
    }
    [cell initAttendanceHasSignOutCellWithEventModel:[self getModelWithIndexPath:indexPath]];
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
    [cell initVisitHasSignOutCellWithEventModel:[self getModelWithIndexPath:indexPath]];
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
    [cell initVisitnoSignOutCellWithEventModel:[self getModelWithIndexPath:indexPath]];
    return cell;
}


#pragma mark -
#pragma mark 界面操作
- (void)initSignDetailViewController
{
    showDateArray = [NSMutableArray arrayWithObject:self.showDate];
    if (self.dateAry) {
        //排序从小到大
        for (int i=0; i<[self.dateAry count]; i++) {
            if ([self.dateAry[i] isEqualToString:self.showDate]) {
                showDateCount = i;
            }
        }
    }
    showPersonArray = [NSMutableArray arrayWithObject:CDOwner.email];
    if (self.personAryArray) {
        //排序从小到大
        for (int i=0; i<[self.personAryArray count]; i++) {
            CDUser *tempPerson = self.personAryArray[i];
            if ([tempPerson.email isEqualToString:CDOwner.email]) {
                showPersonCount = i;
                upperPage = showPersonCount;
            }
        }
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"我的关注" style:UIBarButtonItemStylePlain target:self action:@selector(noticeButtonItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = @"我的事件";
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
    __weak SubSignDetailViewController *block_self = self;
    __weak NSMutableArray *tempUserAry = showPersonArray;
    __weak NSMutableArray *tempDateAry = showDateArray;
        
    __block SEARCHTYPE tempType = currentType;
    refreshFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //当开始加载更多时
        isRefreshIng = NO;
        upperPage++;
        switch (tempType) {
            case SEARCHTYPE_TIME:
                {
                    if (upperPage<block_self.dateAry.count) {
                        NSString * searchDate = block_self.dateAry[upperPage];
                        [tempDateAry addObject:searchDate];
                        [block_self sendRequestGetNewSignDetailDataWithUserModel:nil andDateStr:searchDate];
                    }
                    else
                    {
                        upperPage = block_self.dateAry.count-1;
                        [block_self toast:@"没有更多的信息啦"];
                        [block_self performSelector:@selector(endFreshFooter) withObject:block_self afterDelay:0.05];
                    }
                }
                break;
            case SEARCHTYPE_PERSON:
                {
                    if (upperPage<block_self.personAryArray.count) {
                        CDUser * searchUser = block_self.personAryArray[upperPage];
                        [tempUserAry addObject:searchUser.email];
                        [block_self sendRequestGetNewSignDetailDataWithUserModel:[searchUser toUsersModel] andDateStr:nil];
                    }
                    else
                    {
                        upperPage = block_self.personAryArray.count-1;
                        [block_self toast:@"没有更多的信息啦"];
                        [block_self performSelector:@selector(endFreshFooter) withObject:block_self afterDelay:0.05];
                    }
                }
                break;
            default:
                break;
        }
    };
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
}
#pragma mark -
#pragma mark 回调处理
- (void)findSomeDayOwnSignEventComplete:(NSNotification *)notification
{
    NSDictionary * dic = notification.userInfo;
    if ([self doResponse:dic]) {
        switch (currentType) {
            case SEARCHTYPE_PERSON:
                {
                    if (!self.personAryArray || self.personAryArray.count == 0) {
                        dataSourceDict = [@{self.showDate:dic[@"resultData"]} mutableCopy];
                    }
                    else
                    {
                        if (!dataSourceDict) {
                            dataSourceDict = [@{refresPerson.email:dic[@"resultData"]} mutableCopy];
                        }
                        else
                        {
                            [dataSourceDict setObject:dic[@"resultData"] forKey:refresPerson.email];
                        }
                    }
                }
                break;
            case SEARCHTYPE_TIME:
                {
                    if (!self.dateAry || self.dateAry.count == 0) {
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
                break;
            default:
                break;
        }
    }
    needUpdate = NO;
    isRefreshIng = NO;
    [self performSelector:@selector(endFreshFooter) withObject:self afterDelay:0.2];
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
