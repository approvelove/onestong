//
//  TableListDetailViewController.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "TableListDetailViewController.h"
#import "TableListDetailHeader.h"
#import "TableListDetailCell.h"
#import "CDUserDAO.h"
#import "CDUser.h"
#import "UsersService.h"
#import "Timehelper.h"
#import "SignDetailViewController.h"
#import "segmentView.h"
#import "TimeSelectedViewController.h"
#import "VisitTableViewListDetailCell.h"
#import "VisitTableListDetailHeader.h"
#import "VerifyHelper.h"

@interface TableListDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    NSMutableArray *showNumAry;
    
    NSString *beginDateStr;
    NSString *endDateStr;
    SegmentView *segView;
    VisitTableListDetailHeader *visitTableHeader;
    TableListDetailHeader *tableHeader;
    NSArray *constChartArray;
    NSString *currentUserName;
    
    UIButton *titleButton;
    UILabel *titleLabel;
    NSString *currentSearchDBColumn;
}
@end

@implementation TableListDetailViewController
@synthesize selecteduserId,selectMonth,superBeginDateStr,superEndDateStr,rightItemTitle,navTitleTimeStr;

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
    [self registNotification];
    [self initController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (segView) {
        if (segView.onWindow) {
            [self removeSegViewInAnimation];
            mainTableView.userInteractionEnabled = YES;
        }
    }
    [self saveCurrentTimeString];
}

- (void)dealloc
{
    [self freeNotification];
}
#pragma mark -
#pragma mark 事件处理
- (void)saveCurrentTimeString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{@"title":self.navTitleTimeStr,@"begin":beginDateStr,@"end":endDateStr} forKey:@"selectedTime"];
    [defaults synchronize];
}

- (void)checkButtonClick
{
    if (![BaseService checkReachability]) {
        return;
    }
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        self.navigationItem.rightBarButtonItem.title = @"外访";
        [self onlyCheckAttendanceData];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"考勤";
        [self onlyCheckVisitData];
    }
}

- (void)navTitleBarClick
{
    if (!segView) {
        segView = [SegmentView loadFromNib];
        segView.onWindow = YES;
        float segOriginY = 64;
        if (CURRENT_VERSION<7.0) {
            segOriginY = 0;
        }
        segView.frame = CGRectMake(65, segOriginY, segView.frame.size.width, segView.frame.size.height);
        mainTableView.userInteractionEnabled = NO;
        [segView initializedSegmentView];
        [segView changeButtonColorWithTimeString:self.navTitleTimeStr];
        [self showView:segView.segmentBar];
        
        [segView.todayButton addTarget:self action:@selector(checkTodayEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.yesterdayButton addTarget:self action:@selector(checkYestodayEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.currentWeekButton addTarget:self action:@selector(checkCurrentWeekEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.lastWeekButton addTarget:self action:@selector(checkLastWeekEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.currentMonthButton addTarget:self action:@selector(checkCurrentMonthEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.lastMonthButton addTarget:self action:@selector(checkLastMonthEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [segView.otherDateButton addTarget:self action:@selector(checkOtherMonthEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:segView];
    }
    else
    {
        if (segView.onWindow) {
            [self removeSegViewInAnimation];
            mainTableView.userInteractionEnabled = YES;
        }
    }
}

- (void)checkTodayEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[NSDate date]];
    endDateStr = beginDateStr;
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n今日",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"今日";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkYestodayEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getYesterDay:[NSDate date]]];
    endDateStr = beginDateStr;
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n昨日",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"昨日";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkCurrentWeekEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getBeginDateInWeekWith:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDateInWeekWithDate:[NSDate date]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n本周",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"本周";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkLastWeekEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getlastFirstDayDateWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getlastWeekDayDateWithDate:[NSDate date]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n上周",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"上周";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkCurrentMonthEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getFirstDayDateInCurrentDateMonthWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDayDateInCurrentDateMonthWithDate:[NSDate date]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n本月",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"本月";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkLastMonthEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getFirstDayDateInLastMonthOfDateWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDayDateInLastMonthOfDateWithDate:[NSDate date]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n上月",currentUserName] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    self.navTitleTimeStr = @"上月";
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)checkOtherMonthEventButtonClick:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeSelectedOverNotification:) name:TIME_SELECTED_OVER_NOTIFICATION object:nil];
    TimeSelectedViewController *selectedTimeCtrl = [[TimeSelectedViewController alloc] initWithNibName:@"TimeSelectedViewController" bundle:nil];
    selectedTimeCtrl.navigationItem.title = @"时间选择";
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self.navigationController pushViewController:selectedTimeCtrl animated:YES];
}

//外访部分
- (void)visitTimeItemClick
{
//    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitTimeItem]) {
//        [self searchAllData];
//        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitTimeItem];
//        currentSearchDBColumn = nil;
//    }
}

- (void)visitVisitItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitVisitItem]) {
        [self searchDataWithDBColumn:@"f6"];
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitVisitItem];
        currentSearchDBColumn = @"f6";
    }
}

- (void)visitSignInClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignInItem]) {
        [self searchDataWithDBColumn:@"f7"];
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignInItem];
        currentSearchDBColumn = @"f7";
    }
}

- (void)visitSignOutClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignOutItem]) {
        [self searchDataWithDBColumn:@"f8"];
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignOutItem];
        currentSearchDBColumn = @"f8";
    }
}

//考勤部分
- (void)timeItemClick
{
//    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.dateItem]) {
//        [self searchAllData];
//        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.dateItem];
//        currentSearchDBColumn = nil;
//    }
}

- (void)lateItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.lateItem]) {
        [self searchDataWithDBColumn:@"f6"];
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.lateItem];
        currentSearchDBColumn = @"f6";
    }
}

- (void)earlyOutItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.earlyOutItem]) {
        [self searchDataWithDBColumn:@"f7"];
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.earlyOutItem];
        currentSearchDBColumn = @"f7";
    }
}

- (void)absenteeismItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.absenteeismItem]) {
        [self searchDataWithDBColumn:@"f8"];
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.absenteeismItem];
        currentSearchDBColumn = @"f8";
    }
}

- (void)noSignOutItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.noSignOutItem]) {
        [self searchDataWithDBColumn:@"f9"];
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.noSignOutItem];
        currentSearchDBColumn = @"f9";
    }
}

#pragma mark -
#pragma mark 逻辑处理

- (BOOL)needSearchDataWhenItemClickWithToolBar:(UIToolbar *)toolBar clickItem:(UIBarButtonItem *)item
{
    static UIBarButtonItem *currentClickItem = nil;
    if (currentClickItem&&currentClickItem == item) {
        [self searchAllData];
        [self changeToolBarColorWithToolbar:toolBar clickItem:nil];
        currentClickItem = nil;
        return NO;
    }
    else
    {
        currentClickItem = item;
        return YES;
    }
}

- (void)changeToolBarColorWithToolbar:(UIToolbar *)toolbar clickItem:(UIBarButtonItem *)item
{
    if (toolbar == nil) {
        return;
    }
    for (UIBarButtonItem *temp in [toolbar items]) {
        temp.tintColor = rgbaColor(0.f, 122.f, 255.f, 1.f);//变了之后的颜色
    }
    if (item) {
        item.tintColor = rgbaColor(229, 101, 64, 1.f);
    }
}

- (void)searchAllData
{
    showNumAry = [constChartArray mutableCopy];
    [mainTableView reloadData];
}


- (void)searchDataWithDBColumn:(NSString *)columnName
{
    showNumAry = [@[] mutableCopy];
    for (int i = 0; i<[constChartArray count];i++) {
        NSLog(@"i = %d",i);
        NSDictionary *obj = constChartArray[i];
        int num = [obj[columnName] intValue];
        if (num>0) {
            [showNumAry addObject:obj];
        }
    }
    [mainTableView reloadData];
}

- (void)sendRequestCheckChartInterface
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        [self onlyCheckVisitData];
    }
    else
    {
        [self onlyCheckAttendanceData];
    }
}

- (void)removeSegViewInAnimation
{
    if (segView) {
        segView.shadowView.backgroundColor = [UIColor clearColor];
        [self hideView:segView.segmentBar];
    }
}

- (void)showView:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [view.layer addAnimation:animation forKey:nil];
}

- (void)hideView:(UIView *)view
{
    [UIView animateWithDuration:0.2f animations:^(void){
        //animationView.hidden = NO;
        view.frame = CGRectMake(0, -265, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL result){
        [self clearSegmentView];
    }];
}

- (void)clearSegmentView
{
    if (segView) {
        [segView removeFromSuperview];
        segView = nil;
    }
}

- (void)onlyCheckAttendanceData
{
    [self sendRequestGetAttendanceChartWithBeginDate:beginDateStr endDate:endDateStr];
}

- (void)onlyCheckVisitData
{
    [self sendRequestGetVisitChartWithBeginDate:beginDateStr endDate:endDateStr];
}

- (void)sendRequestGetAttendanceChartWithBeginDate:(NSString *)beginDate endDate:(NSString *)endDate
{
    [self startLoading];
    UsersService *service = [[UsersService alloc] init];
    [service getUserChartsWithUserId:self.selecteduserId beginDate:beginDate endDate:endDate chartType:CHART_TYPE_ATTENDANCE];
}

- (void)sendRequestGetVisitChartWithBeginDate:(NSString *)beginDate endDate:(NSString *)endDate
{
    [self startLoading];
    UsersService *service = [[UsersService alloc] init];
    [service getUserChartsWithUserId:self.selecteduserId beginDate:beginDate endDate:endDate chartType:CHART_TYPE_VISIT];
}


- (void)getAttendanceChartComplete:(NSNotification *)notification
{
    [self stopLoading];
    if (notification.userInfo) {
        constChartArray = [self doResponse:notification.userInfo];
        currentSearchDBColumn?[self searchDataWithDBColumn:currentSearchDBColumn]:[self searchAllData];
    }
    if (segView) {
        if (segView.onWindow) {
            [self removeSegViewInAnimation];
            mainTableView.userInteractionEnabled = YES;
        }
    }
}

- (void)timeSelectedOverNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_SELECTED_OVER_NOTIFICATION object:nil];
    beginDateStr = notification.userInfo[@"start"]?notification.userInfo[@"start"]:@"";
    endDateStr = notification.userInfo[@"end"]?notification.userInfo[@"end"]:@"";
    
    NSString *timeStr = [NSString stringWithFormat:@"%@至%@",[TimeHelper getYearMonthDayWithDateInChinese:[TimeHelper dateFromString:beginDateStr]],[TimeHelper getYearMonthDayWithDateInChinese:[TimeHelper dateFromString:endDateStr]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n%@",currentUserName,timeStr] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
    self.navTitleTimeStr = timeStr;
    titleLabel.text = self.navTitleTimeStr;
    [self sendRequestCheckChartInterface];
}

- (void)getVisitChartComplete:(NSNotification *)notification
{
    [self stopLoading];
    if (notification.userInfo) {
        constChartArray = [self doResponse:notification.userInfo];
//        showNumAry = [constChartArray mutableCopy];
//        [mainTableView reloadData];
        currentSearchDBColumn?[self searchDataWithDBColumn:currentSearchDBColumn]:[self searchAllData];
    }
    if (segView) {
        if (segView.onWindow) {
            [self removeSegViewInAnimation];
            mainTableView.userInteractionEnabled = YES;
        }
    }
}
#pragma mark -
#pragma mark 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (showNumAry) {
        return [showNumAry count];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        if (!visitTableHeader) {
            visitTableHeader = [VisitTableListDetailHeader loadFromNib];
            visitTableHeader.visitTimeItem.action = @selector(visitTimeItemClick);
            visitTableHeader.visitVisitItem.action = @selector(visitVisitItemClick);
            visitTableHeader.visitSignInItem.action = @selector(visitSignInClick);
            visitTableHeader.visitSignOutItem.action = @selector(visitSignOutClick);
        }
        return visitTableHeader;
    }
    else
    {
        if (!tableHeader) {
            tableHeader = [TableListDetailHeader loadFromNib];
            tableHeader.dateItem.action = @selector(timeItemClick);
            tableHeader.lateItem.action = @selector(lateItemClick);
            tableHeader.earlyOutItem.action = @selector(earlyOutItemClick);
            tableHeader.absenteeismItem.action = @selector(absenteeismItemClick);
            tableHeader.noSignOutItem.action = @selector(noSignOutItemClick);
        }
        if (tableHeader) {
            tableHeader.noSignOutItem.title = [self.navTitleTimeStr isEqualToString:@"今日"]?@"待签退":@"未签退";
        }
        return tableHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        VisitTableViewListDetailCell * cell = [self setVisitTablistDetailCellWithTableView:tableView indexPath:indexPath];
        return cell;
    }
    else
    {
        TableListDetailCell *cell = [self setAttendanceTablistDetailCellWithTableView:tableView indexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SignDetailViewController *detailCtrl = [[SignDetailViewController alloc] initWithNibName:@"SignDetailViewController" bundle:nil];
    UsersModel *model = [[UsersModel alloc] init];
    model.userId = self.selecteduserId;
    detailCtrl.currentUser = model;
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        VisitTableViewListDetailCell *cell = (VisitTableViewListDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
        detailCtrl.showDate = cell.timeLabel.text;
        detailCtrl.eventMethod = SHOWEVENT_VISIT;
    }
    else
    {
        TableListDetailCell *cell = (TableListDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
        detailCtrl.showDate = cell.dateLabel.text;
        detailCtrl.eventMethod = SHOWEVENT_ATTENDANCE;
    }
    NSMutableArray *tempDateAry = [@[] mutableCopy];
    for (int i =0; i<constChartArray.count; i++) {
        NSString *dateStr = constChartArray[i][@"f3"];
        [tempDateAry addObject:dateStr];
    }
    detailCtrl.dateArray = tempDateAry;
    [self.navigationController pushViewController:detailCtrl animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeSegViewInAnimation];
    mainTableView.userInteractionEnabled = YES;
}

- (VisitTableViewListDetailCell *)setVisitTablistDetailCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VisitTableViewListDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [VisitTableViewListDetailCell loadFromNib];
    }
    NSDictionary *formInfo = showNumAry[indexPath.row];
    cell.timeLabel.text = formInfo[@"f3"];
    cell.visitLabel.text = formInfo[@"f6"];
    cell.signInLabel.text = formInfo[@"f7"];
    cell.signOutLabel.text = formInfo[@"f8"];
    return cell;
}

- (TableListDetailCell *)setAttendanceTablistDetailCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    TableListDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [TableListDetailCell loadFromNib];
    }
    NSDictionary *formInfo = showNumAry[indexPath.row];
    cell.dateLabel.text = formInfo[@"f3"];
    cell.lateLabe.text = formInfo[@"f6"];
    cell.earlyOutLabel.text = formInfo[@"f7"];
    cell.absenteeismLabel.text = formInfo[@"f8"];
    if (formInfo[@"f9"]&&[formInfo[@"f9"] isEqualToString:@"1"]) {
        cell.noSignOutImageView.image = [UIImage imageNamed:@"delete_button"];
    }
    return cell;
}
#pragma mark -
#pragma mark 界面处理
- (void)initController
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:self.rightItemTitle style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self showNavTitle];
    beginDateStr = self.superBeginDateStr;
    endDateStr = self.superEndDateStr;
    [self sendRequestCheckChartInterface];
}

- (void)showNavTitle
{
    CDUser *user = [[[CDUserDAO alloc] init] findById:self.selecteduserId];
    currentUserName = user.username;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 280, 44)];
    titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(2.5, 6, 180, 33);
    [titleButton addTarget:self action:@selector(navTitleBarClick) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTitle:[NSString stringWithFormat:@"%@",currentUserName] forState:UIControlStateNormal];
    //    titleButton.backgroundColor = [UIColor greenColor];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleButton setTitleColor:rgbaColor(81.f, 143.f, 252.f, 1.f) forState:UIControlStateNormal];
    [titleView addSubview:titleButton];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 30, 180, 13)];
    [titleView addSubview:titleLabel];
    //    titleLabel.text = @"2014年10月11日至2014年11月30日";
    //    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.text = self.navTitleTimeStr;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:11.f];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
    UIImageView *markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(titleButton.titleLabel.frame.origin.x+titleButton.titleLabel.frame.size.width, 16, 6, 6)];
    markImageView.image = [UIImage imageNamed:@"pull-down.png"];
    [titleButton addSubview:markImageView];
}
#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAttendanceChartComplete:) name:GET_USER_ATTENDANCE_CHART_MONTH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVisitChartComplete:) name:GET_USER_VISIT_CHART_MONTH_NOTIFICATION object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
