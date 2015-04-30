//
//  VisitTabListViewController.m
//  VisitTabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "VisitTabListViewController.h"
#import "VisitTabelListHeader.h"
#import "VisitTableListCell.h"
#import "VisitTableListDetailController.h"
#import "DepartmentsService.h"
#import "CDDepartment.h"
#import "TimeHelper.h"
#import "SegmentView.h"


@interface VisitTabListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSInteger monthNum;
    NSMutableArray *showChartArray;
    NSMutableArray *constChartArray;
    
    VisitTabelListHeader *tableHeader;
    __weak IBOutlet UITableView *mainTableView;
    SegmentView *segView;
}
@end

@implementation VisitTabListViewController
@synthesize selectedDepartment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registNotification];
    [self initVisitTabListViewController];
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
- (void)navbarNextItemClick
{
    if (monthNum == 12) {
        monthNum = 1;
    }
    else
    {
        monthNum++;
    }
    [self showNavTitleWithMonth:monthNum];
    [self sendRequestGetVisitDataWithMonth:monthNum];
}

- (void)navbarBeforeItemClick
{
    if (monthNum == 1) {
        monthNum =12;
    }
    else
    {
        monthNum--;
    }
    [self showNavTitleWithMonth:monthNum];
    [self sendRequestGetVisitDataWithMonth:monthNum];
}


- (void)navTitleBarClick
{
    if (!segView) {
        segView = [SegmentView loadFromNib];
        segView.onWindow = YES;
        segView.frame = CGRectMake(0, 64, 320, 75);
        mainTableView.userInteractionEnabled = NO;
        [self showView:segView.segmentBar];
        [self.view addSubview:segView];
    }
    else
    {
        if (segView.onWindow) {
           [self removeSegViewInAnimation];
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
    if (showChartArray) {
        return [showChartArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!tableHeader) {
        tableHeader = [VisitTabelListHeader loadFromNib];
        tableHeader.mainSearchBar.delegate = self;
    }
    return tableHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 88.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VisitTableListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [VisitTableListCell loadFromNib];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *chartDataDic = showChartArray[indexPath.row];
    cell.nameLabel.text = chartDataDic[@"f2"];
    cell.visitLabel.text = chartDataDic[@"f6"];
    cell.userId = chartDataDic[@"f1"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitTableListCell *cell = (VisitTableListCell *)[tableView cellForRowAtIndexPath:indexPath];
    VisitTableListDetailController *tldCtrl = [[VisitTableListDetailController alloc] initWithNibName:@"VisitTableListDetailController" bundle:nil];
    tldCtrl.selectedUserId = cell.userId;
    tldCtrl.selectMonth = monthNum;
    [self.navigationController pushViewController:tldCtrl animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchStringWithString:searchText];
    [searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if (touchPoint.y>= 139) {
        [self removeSegViewInAnimation];
    }
    
}

#pragma mark -
#pragma mark 界面处理
- (void)initVisitTabListViewController
{
    UIBarButtonItem *nav_next_item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"buttondown"] style:UIBarButtonItemStylePlain target:self action:@selector(navbarNextItemClick)];
    UIBarButtonItem *nav_before_item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"buttonup"] style:UIBarButtonItemStylePlain target:self action:@selector(navbarBeforeItemClick)];
    self.navigationItem.rightBarButtonItems = @[nav_before_item,nav_next_item];
    NSDateComponents *comps = [TimeHelper getDateComponents];
    monthNum = comps.month;
    [self showNavTitleWithMonth:monthNum];
    [self sendRequestGetVisitDataWithMonth:monthNum];
}

#pragma mark -
#pragma mark 逻辑处理


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
    CATransition *transition = [CATransition animation];
    transition.duration =0.2;
    [transition setFillMode:kCAFillModeBackwards];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    [view.layer addAnimation:transition forKey:@"Reveal"];
    [self performSelector:@selector(clearSegmentView) withObject:self afterDelay:0.05];
}

- (void)clearSegmentView
{
    if (segView) {
        [segView removeFromSuperview];
        segView = nil;
    }
}

- (void)sendRequestGetVisitDataWithMonth:(NSInteger)mon
{
    [self startLoading];
//    NSDateComponents *comps = [TimeHelper getDateComponents];
//    NSString *dateStr = [NSString stringWithFormat:@"%ld-%02d",(long)comps.year,mon];
//    DepartmentsService *service = [[DepartmentsService alloc] init];
//    [service getDepartmentMonthVisitChartWithDepartmentId:self.selectedDepartment.deptId andDate:dateStr];
}

- (void)showNavTitleWithMonth:(NSInteger)mon
{
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton addTarget:self action:@selector(navTitleBarClick) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTitle:[NSString stringWithFormat:@"%d月%@",mon,self.selectedDepartment.deptname] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleButton;
}

- (void)resignResponder
{
    if (tableHeader) {
        [tableHeader.mainSearchBar resignFirstResponder];
    }
}

- (void)searchStringWithString:(NSString *)searchText
{
    if (!searchText||[searchText isEqualToString:@""]) {
        showChartArray = [constChartArray mutableCopy];
    }
    else
    {
        showChartArray = [@[] mutableCopy];
        for (int i = 0; i<[constChartArray count];i++) {
            NSLog(@"i = %d",i);
            NSDictionary *obj = constChartArray[i];
            NSRange tempRange = [obj[@"f2"] rangeOfString:searchText];
            if (tempRange.length>0) {
                [showChartArray addObject:obj];
            }
        }
    }
    [mainTableView reloadData];
}

- (void)getChartDataComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]||[[self doResponse:notification.userInfo] isKindOfClass:[NSArray class]]) {
        constChartArray = [self doResponse:notification.userInfo];
        showChartArray = [constChartArray mutableCopy];
        [mainTableView reloadData];
    }
}


#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChartDataComplete:) name:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
