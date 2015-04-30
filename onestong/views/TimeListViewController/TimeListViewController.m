//
//  TimeListViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "TimeListViewController.h"
#import "MJRefresh.h"

#import "SignDetailViewController.h"
#import "EventsService.h"
#import "TimeHelper.h"

#import "DailyAttendanceStatisticsService.h"
#import "MapPathViewController.h"
#import "VerifyHelper.h"

static const int CELL_HEIGHT = 50;
static int page = 1;
static BOOL isRefreshIng = NO;

@interface TimeListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    __weak IBOutlet UITableView *mainTable;
    MJRefreshHeaderView *header;
    MJRefreshFooterView *footer;
    NSMutableArray * tableDataArr;
}
@end

@implementation TimeListViewController
@synthesize user,eventType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - 
#pragma mark 系统界面操作

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTimeListViewCtrl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self freeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self refreshCtrlFree];
}
#pragma mark -
#pragma mark  事件处理

- (void)rightButtonItemClick
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"外访"]) {
        self.navigationItem.rightBarButtonItem.title = @"考勤";
        self.navigationItem.title = @"外访一览";
        self.eventType = EVENTTYPE_VISIT;
        
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"外访";
        self.navigationItem.title = @"考勤一览";
        self.eventType = EVENTTYPE_ATTENDANCE;
    }
    page = 1;
    isRefreshIng = YES;
    [self findAllOwnSignEventsByPage:page];
}
#pragma mark -
#pragma mark  逻辑处理

- (void)findCanlendarDateCompleteWithPage:(int)page
{
    if (isRefreshIng) {
        [tableDataArr removeAllObjects];
        tableDataArr = nil;
    }
    if ((tableDataArr)||(![tableDataArr count]==0)) {
        [tableDataArr addObjectsFromArray:[TimeHelper getNextPageDays:page]];
    }
    else
    {
        tableDataArr = [TimeHelper getNextPageDays:page];
    }
    [mainTable reloadData];
    [self performSelector:@selector(endFreshHeader) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(endFreshFooter) withObject:nil afterDelay:0.5];
}


- (void)findDailyAttendanceComplete:(NSNotification *)notification
{
    
    if (isRefreshIng) {
        [tableDataArr removeAllObjects];
        tableDataArr = nil;
    }
    if ([self doResponse:notification.userInfo]) {
        if ((tableDataArr)||(![tableDataArr count]==0)) {
            [tableDataArr addObjectsFromArray:notification.userInfo[@"resultData"]];
        }
        else
        {
            tableDataArr = [NSMutableArray arrayWithArray:notification.userInfo[@"resultData"]];
        }
    }
    [mainTable reloadData];
    [self performSelector:@selector(endFreshHeader) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(endFreshFooter) withObject:nil afterDelay:0.5];
}


-(void)findAllOwnSignEventsByPage:(int)page
{
    DailyAttendanceStatisticsService *service = [[DailyAttendanceStatisticsService alloc] init];
    UsersModel *owner = [service getCurrentUser];
    switch (self.eventType) {
        case EVENTTYPE_ATTENDANCE:
            [service findOwnSignStatistics:(user?self.user.userId:owner.userId) andPageNum:page];
            break;
        case EVENTTYPE_VISIT:
            [service findOwnStatistics:(user?self.user.userId:owner.userId) andPageNum:page];
            break;
        case EVENTTYPE_EVENT_MAPPATH:
            [service findOwnStatistics:(user?self.user.userId:owner.userId) andPageNum:page];
            break;
        case EVENTTYPE_DEVICE_MAPPATH:
            [self findCanlendarDateCompleteWithPage:page];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark 登录界面 数据展示操作


#pragma mark -
#pragma mark  界面处理
- (void)initTimeListViewCtrl
{
    [self addHeader];
    [self addFooter];
    page = 1;
    if (self.eventType == EVENTTYPE_ATTENDANCE || self.eventType == EVENTTYPE_VISIT) {
        [self addItemBackToHomePage];
    }
    [self findAllOwnSignEventsByPage:page];
}

- (void)addItemBackToHomePage
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"外访" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addHeader
{
    if (header == nil) {
        header = [MJRefreshHeaderView header];
        header.scrollView = mainTable;
        __weak TimeListViewController *block_self = self;
        header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            page = 1;
            isRefreshIng = YES;
            [block_self findAllOwnSignEventsByPage:page];
        };
    }
}

- (void)endFreshHeader
{
    if (header) {
        [header endRefreshingWithoutIdle];
    }
}

- (void)addFooter
{
    if (footer == nil) {
        footer = [MJRefreshFooterView footer];
        footer.scrollView = mainTable;
        __weak TimeListViewController *block_self = self;
        footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            //当开始加载更多时
            page++;
            isRefreshIng = NO;
            [block_self findAllOwnSignEventsByPage:page];
        };
    }
}

- (void)endFreshFooter
{
    if (footer) {
        [footer endRefreshingWithoutIdle];
    }
}

- (void)refreshCtrlFree
{
    [header free];
    [footer free];
}

#pragma mark - 
#pragma mark  代理处理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableDataArr) {
        return [tableDataArr count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellOne"];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    if (self.eventType == EVENTTYPE_DEVICE_MAPPATH) {
        NSArray *tempAry = [tableDataArr[indexPath.row] componentsSeparatedByString:@" "];
        cell.textLabel.text = tempAry[0];
        cell.detailTextLabel.text = tempAry[1];
        if ([tempAry[1] isEqualToString:@"星期六"]||[tempAry[1] isEqualToString:@"星期日"]) {
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    else
    {
        DailyAttendanceStatisticsModel *dailyModel = tableDataArr[indexPath.row];
        cell.textLabel.text = dailyModel.signDate;
        if (self.eventType == EVENTTYPE_VISIT) {
            NSString *signDescriptionStr = [NSString stringWithFormat:@"已签到:%d  已签退:%d",dailyModel.signInNum,dailyModel.signOutNum];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:signDescriptionStr];
            NSRange signInRange = [signDescriptionStr rangeOfString:@"已签到"];
            NSRange signOutRange = [signDescriptionStr rangeOfString:@"已签退"];
            
            NSDictionary *signInAttributes = @{NSForegroundColorAttributeName:rgbaColor(242.f, 177.f, 177.f, 1.f)};
            NSDictionary *signOutAttributes = @{NSForegroundColorAttributeName:rgbaColor(212.f, 233.f, 133.f, 1)};
            [attributedStr setAttributes:signInAttributes range:signInRange];
            [attributedStr setAttributes:signOutAttributes range:signOutRange];
            cell.detailTextLabel.attributedText = attributedStr;
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSArray *)getDateAry
{
    NSMutableArray *tempDateAry = [@[] mutableCopy];
    for (int i=0; i<[tableDataArr count]; i++) {
        DailyAttendanceStatisticsModel *dailyModel = tableDataArr[i];
        if (![VerifyHelper isEmpty:dailyModel.signDate]) {
            [tempDateAry addObject:dailyModel.signDate];
        }
    }
    return tempDateAry;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (self.eventType) {
        case EVENTTYPE_ATTENDANCE:
        {
            SignDetailViewController *signDetailViewController = [[SignDetailViewController alloc] initWithNibName:@"SignDetailViewController" bundle:nil];
            signDetailViewController.currentUser = self.user;
            signDetailViewController.showDate = cell.textLabel.text;
            signDetailViewController.eventMethod = SHOWEVENT_ATTENDANCE;
            signDetailViewController.dateArray = [self getDateAry];
            [self.navigationController pushViewController:signDetailViewController animated:YES];
        }
            break;
        case EVENTTYPE_VISIT:
        {
            SignDetailViewController *signDetailViewController = [[SignDetailViewController alloc] initWithNibName:@"SignDetailViewController" bundle:nil];
            signDetailViewController.currentUser = self.user;
            signDetailViewController.showDate = cell.textLabel.text;
            signDetailViewController.eventMethod = SHOWEVENT_VISIT;
            signDetailViewController.dateArray = [self getDateAry];
            [self.navigationController pushViewController:signDetailViewController animated:YES];
        }
            break;
       case EVENTTYPE_DEVICE_MAPPATH:
        {
            MapPathViewController *mapCtrl = [[MapPathViewController alloc] initWithNibName:@"MapPathViewController" bundle:nil];
            mapCtrl.currentUser = self.user;
            mapCtrl.showDate = cell.textLabel.text;
            mapCtrl.currentShow = SHOWPOINT_DEVICE;
            [self.navigationController pushViewController:mapCtrl animated:YES];
        }
            break;
       case EVENTTYPE_EVENT_MAPPATH:
        {
            MapPathViewController *mapCtrl = [[MapPathViewController alloc] initWithNibName:@"MapPathViewController" bundle:nil];
            mapCtrl.showDate = cell.textLabel.text;
            mapCtrl.currentUser = self.user;
            mapCtrl.currentShow = SHOWPOINT_EVENT;
            [self.navigationController pushViewController:mapCtrl animated:YES];
        }
            break;
    }
}

#pragma mark -
#pragma mark 视图通知管理
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDailyAttendanceComplete:) name:FIND_OWN_STATISTICS_NOTIFICATION object:nil];
}

-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_OWN_STATISTICS_NOTIFICATION object:nil];
}
@end
