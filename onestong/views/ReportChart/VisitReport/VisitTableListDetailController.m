//
//  VisitTableListDetailController.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "VisitTableListDetailController.h"
#import "VisitTableListDetailHeader.h"
#import "VisitTableViewListDetailCell.h"
#import "CDUserDAO.h"
#import "CDUser.h"
#import "UsersService.h"
#import "Timehelper.h"
#import "SignDetailViewController.h"

@interface VisitTableListDetailController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *showNumAry;
    __weak IBOutlet UITableView *mainTableView;
}
@end

@implementation VisitTableListDetailController
@synthesize selectedUserId,selectMonth,superEndDateStr,superBeginDateStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - 系统方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registNotification];
    [self initVisitTableListDetailController];
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


#pragma mark -
#pragma mark 逻辑处理
- (void)sendRequestGetVisitChart
{
//    UsersService *service = [[UsersService alloc] init];
//    NSDateComponents *comps = [TimeHelper getDateComponents];
//    NSString *dateStr = [NSString stringWithFormat:@"%d-%02d",comps.year,self.selectMonth];
//    [service getUserMonthVisitChartWithUserId:self.selectedUserId andDate:dateStr];
}

- (void)getVisitChartComplete:(NSNotification *)notification
{
    if (notification.userInfo) {
        showNumAry = [self doResponse:notification.userInfo];
        [mainTableView reloadData];
    }
}
#pragma mark -
#pragma mark 界面处理
- (void)initVisitTableListDetailController
{
    CDUser *user = [[[CDUserDAO alloc] init] findById:self.selectedUserId];
    self.navigationItem.title = user.username;
    [self sendRequestGetVisitChart];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    VisitTableListDetailHeader *header = [VisitTableListDetailHeader loadFromNib];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VisitTableViewListDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [VisitTableViewListDetailCell loadFromNib];
    }
    NSDictionary *formInfo = showNumAry[indexPath.row];
    cell.timeLabel.text = formInfo[@"f3"];
    cell.visitLabel.text = formInfo[@"f6"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitTableViewListDetailCell *cell = (VisitTableViewListDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
    SignDetailViewController *detailCtrl = [[SignDetailViewController alloc] initWithNibName:@"SignDetailViewController" bundle:nil];
    detailCtrl.showDate = cell.timeLabel.text;
    detailCtrl.eventMethod = SHOWEVENT_VISIT;
    UsersModel *model = [[UsersModel alloc] init];
    model.userId = self.selectedUserId;
    detailCtrl.currentUser = model;
    [self.navigationController pushViewController:detailCtrl animated:YES];
}

#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVisitChartComplete:) name:GET_USER_VISIT_CHART_MONTH_NOTIFICATION object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_USER_VISIT_CHART_MONTH_NOTIFICATION object:nil];
}
@end
