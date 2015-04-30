//
//  TabListViewController.m
//  TabList
//
//  Created by 李健 on 14-5-29.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "TabListViewController.h"
#import "TableHeader.h"
#import "TableListCell.h"
#import "TableListDetailViewController.h"
#import "CDDepartment.h"
#import "TimeHelper.h"
#import "DepartmentsService.h"
#import "segmentView.h"
#import "VisitTableListCell.h"
#import "VisitTabelListHeader.h"
#import "TimeSelectedViewcontroller.h"
#import "VerifyHelper.h"

@interface TabListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *showChartArray;
    NSMutableArray *constChartArray;
    SegmentView *segView;
    
    TableHeader *tableHeader;
    
    VisitTabelListHeader *visitTableHeader;
    __weak IBOutlet UITableView *mainTableView;
    
    UIButton *titleButton;
    NSString *beginDateStr;
    NSString *endDateStr;
    
    NSString *timeString;
    UILabel *navTitleLabel;
    NSString *currentSearchDBColumn;
    BOOL fromTimeSelectorCtrl;
}
@end

@implementation TabListViewController
@synthesize selectedDepartment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fromTimeSelectorCtrl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registNotification];
    [self initTabListViewController];
    fromTimeSelectorCtrl = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (fromTimeSelectorCtrl) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDic = [defaults objectForKey:@"selectedTime"];
    if ([VerifyHelper isEmpty:tempDic[@"title"]]) {
        [self checkTodayEventButtonClick:nil];
    }
    else
    {
        [self initDataListWithDefaultsInfo:tempDic];
    }
}

- (void)initDataListWithDefaultsInfo:(NSDictionary *)tempDic
{
    timeString = tempDic[@"title"];
    if (timeString.length>2) {
        beginDateStr = tempDic[@"begin"];
        endDateStr = tempDic[@"end"];
        navTitleLabel.text = timeString;
        [self sendRequestCheckChartInterface];
    }
    else
    {
        NSDictionary *methodDic = @{@"今日":@"checkTodayEventButtonClick:",@"昨日":@"checkYestodayEventButtonClick:",@"本周":@"checkCurrentWeekEventButtonClick:",@"上周":@"checkLastWeekEventButtonClick:",@"本月":@"checkCurrentMonthEventButtonClick:",@"上月":@"checkLastMonthEventButtonClick:"};
        NSString *methodStr = methodDic[timeString];
        if ([self respondsToSelector:NSSelectorFromString(methodStr)]) {
            [self performSelector:NSSelectorFromString(methodStr) withObject:nil afterDelay:0.f];
        }
    }
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
- (void)saveCurrentTimeString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{@"title":timeString,@"begin":beginDateStr,@"end":endDateStr} forKey:@"selectedTime"];
    [defaults synchronize];
}

- (void)backButtonItemClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

////考勤部分
//- (void)nameItemClick
//{
////    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.nameItem]) {
////        [self searchAllData];
////        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.nameItem];
////        currentSearchDBColumn = nil;
////    }
//}

- (void)lateItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.lateItem]) {
        [self searchDataWithDBColumn:@"f6"];
        currentSearchDBColumn = @"f6";
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.lateItem];
    }
}

- (void)earlyOutItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.earlyOutItem]) {
        [self searchDataWithDBColumn:@"f7"];
        currentSearchDBColumn = @"f7";
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.earlyOutItem];
    }
}

- (void)absenteeismItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.absenteeismItem]) {
        [self searchDataWithDBColumn:@"f8"];
        currentSearchDBColumn = @"f8";
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.absenteeismItem];
    }
}

- (void)noSignOutItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.noSignOutItem]) {
        [self searchDataWithDBColumn:@"f9"];
        currentSearchDBColumn = @"f9";
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.noSignOutItem];
    }
}

- (void)visitItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:tableHeader.mainToolBar clickItem:tableHeader.visitItem]) {
        [self searchDataWithDBColumn:@"f10"];
        currentSearchDBColumn = @"f10";
        [self changeToolBarColorWithToolbar:tableHeader.mainToolBar clickItem:tableHeader.visitItem];
    }
}

//外访部分
- (void)visitNameItemClick
{
//    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitNameItem]) {
//        [self searchAllData];
//        currentSearchDBColumn = nil;
//        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitNameItem];
//    }
}

- (void)visitVisitItemClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitVisitItem]) {
        [self searchDataWithDBColumn:@"f6"];
        currentSearchDBColumn = @"f6";
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitVisitItem];
    }
}

- (void)visitSignInClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignInItem]) {
        [self searchDataWithDBColumn:@"f7"];
        currentSearchDBColumn = @"f7";
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignInItem];
    }
}

- (void)visitSignOutClick
{
    if ([self needSearchDataWhenItemClickWithToolBar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignOutItem]) {
        [self searchDataWithDBColumn:@"f8"];
        currentSearchDBColumn = @"f8";
        [self changeToolBarColorWithToolbar:visitTableHeader.mainToolBar clickItem:visitTableHeader.visitSignOutItem];
    }
}

- (NSMutableAttributedString *)setButtonAttributeTitleWithString:(NSString *)aString otherString:(NSString *)bString
{
    NSString *descriptionStr = [NSString stringWithFormat:@"%@\n%@",aString,bString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:descriptionStr];
    NSRange titleRange = [descriptionStr rangeOfString:aString];
    NSRange subTitleRange = [descriptionStr rangeOfString:bString];
    
    NSDictionary *signInAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.f]};
    NSDictionary *signOutAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11.f]};
    [attributedStr setAttributes:signInAttributes range:titleRange];
    [attributedStr setAttributes:signOutAttributes range:subTitleRange];
    return attributedStr;
}

- (void)checkTodayEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[NSDate date]];
    endDateStr = beginDateStr;
    
    timeString = @"今日";
    navTitleLabel.text = timeString;

    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkYestodayEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getYesterDay:[NSDate date]]];
    endDateStr = beginDateStr;
    
    timeString = @"昨日";
    navTitleLabel.text = timeString;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkCurrentWeekEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getBeginDateInWeekWith:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDateInWeekWithDate:[NSDate date]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n本周",self.selectedDepartment.deptname] forState:UIControlStateNormal];
    timeString = @"本周";
    navTitleLabel.text = timeString;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkLastWeekEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getlastFirstDayDateWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getlastWeekDayDateWithDate:[NSDate date]]];
    timeString = @"上周";
    navTitleLabel.text = timeString;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkCurrentMonthEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getFirstDayDateInCurrentDateMonthWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDayDateInCurrentDateMonthWithDate:[NSDate date]]];
    timeString = @"本月";
    navTitleLabel.text = timeString;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkLastMonthEventButtonClick:(UIButton *)sender
{
    beginDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getFirstDayDateInLastMonthOfDateWithDate:[NSDate date]]];
    endDateStr = [TimeHelper getYearMonthDayWithDate:[TimeHelper getEndDayDateInLastMonthOfDateWithDate:[NSDate date]]];
    timeString = @"上月";
    navTitleLabel.text = timeString;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [self sendRequestCheckChartInterface];
}

- (void)checkOtherMonthEventButtonClick:(UIButton *)sender
{
    if (segView) {
        [segView changeButtonColorWhenClick:sender];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeSelectedOverNotification:) name:TIME_SELECTED_OVER_NOTIFICATION object:nil];
    TimeSelectedViewController *selectedTimeCtrl = [[TimeSelectedViewController alloc] initWithNibName:@"TimeSelectedViewController" bundle:nil];
    selectedTimeCtrl.navigationItem.title = @"时间选择";
    [self.navigationController pushViewController:selectedTimeCtrl animated:YES];
}

- (void)checkButtonClick
{
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
        [segView changeButtonColorWithTimeString:timeString];
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
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        if (!visitTableHeader) {
            visitTableHeader = [VisitTabelListHeader loadFromNib];
            visitTableHeader.mainSearchBar.delegate = self;
            visitTableHeader.visitNameItem.action = @selector(visitNameItemClick);
            visitTableHeader.visitVisitItem.action = @selector(visitVisitItemClick);
            visitTableHeader.visitSignInItem.action = @selector(visitSignInClick);
            visitTableHeader.visitSignOutItem.action = @selector(visitSignOutClick);
        }
        return visitTableHeader;
    }
    else
    {
        if (!tableHeader) {
            tableHeader = [TableHeader loadFromNib];
            tableHeader.mainSearchBar.delegate = self;
            tableHeader.nameItem.action = @selector(nameItemClick);
            tableHeader.lateItem.action = @selector(lateItemClick);
            tableHeader.earlyOutItem.action = @selector(earlyOutItemClick);
            tableHeader.absenteeismItem.action = @selector(absenteeismItemClick);
            tableHeader.noSignOutItem.action = @selector(noSignOutItemClick);
            tableHeader.visitItem.action = @selector(visitItemClick);
        }
        if (tableHeader) {
            tableHeader.noSignOutItem.title = [timeString isEqualToString:@"今日"]?@"待签退":@"未签退";
        }
        return tableHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 88.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        VisitTableListCell *cell = [self setVisitCellValueWithTabelView:tableView indexPath:indexPath];
        return cell;
    }
    else
    {
      TableListCell *cell = [self setAttenDanceCellValueWithTabelView:tableView indexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableListCell *cell = (TableListCell *)[tableView cellForRowAtIndexPath:indexPath];
    TableListDetailViewController *tldCtrl = [[TableListDetailViewController alloc] initWithNibName:@"TableListDetailViewController" bundle:nil];
    tldCtrl.selecteduserId = cell.userId;
    tldCtrl.superBeginDateStr = beginDateStr;
    tldCtrl.superEndDateStr = endDateStr;
    tldCtrl.rightItemTitle = self.navigationItem.rightBarButtonItem.title;
    tldCtrl.navTitleTimeStr = timeString;
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
    [self removeSegViewInAnimation];
    mainTableView.userInteractionEnabled = YES;
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
        currentSearchDBColumn = nil;
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
    showChartArray = [constChartArray mutableCopy];
    [mainTableView reloadData];
}

- (void)setSearchBarPlaceHolder:(NSString *)str
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"考勤"]) {
        if (visitTableHeader) {
            visitTableHeader.mainSearchBar.placeholder = str;
        }
    }
    else
    {
        if (tableHeader) {
            tableHeader.mainSearchBar.placeholder = str;
        }
    }
}

- (void)searchDataWithDBColumn:(NSString *)columnName
{
    showChartArray = [@[] mutableCopy];
    for (int i = 0; i<[constChartArray count];i++) {
        NSLog(@"i = %d",i);
        NSDictionary *obj = constChartArray[i];
        int num = [obj[columnName] intValue];
        if (num>0) {
            [showChartArray addObject:obj];
        }
    }
    [mainTableView reloadData];
}

- (void)timeSelectedOverNotification:(NSNotification *)notification
{
    fromTimeSelectorCtrl = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_SELECTED_OVER_NOTIFICATION object:nil];
    beginDateStr = notification.userInfo[@"start"]?notification.userInfo[@"start"]:@"";
    endDateStr = notification.userInfo[@"end"]?notification.userInfo[@"end"]:@"";
    NSString *timeStr = [NSString stringWithFormat:@"%@至%@",[TimeHelper getYearMonthDayWithDateInChinese:[TimeHelper dateFromString:beginDateStr]],[TimeHelper getYearMonthDayWithDateInChinese:[TimeHelper dateFromString:endDateStr]]];
//    [titleButton setTitle:[NSString stringWithFormat:@"%@\n%@",self.selectedDepartment.deptname,timeStr] forState:UIControlStateNormal];
    timeString = timeStr;
//    titleButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
    navTitleLabel.text = timeString;
    [self saveCurrentTimeString];
    [self sendRequestCheckChartInterface];
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

- (void)onlyCheckAttendanceData
{
    [self sendRequestGetAttendanceDataWithBeginDate:beginDateStr endDate:endDateStr];
}

- (void)onlyCheckVisitData
{
    [self sendRequestGetVisitDataWithBeginDate:beginDateStr endDate:endDateStr];
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

- (void)resignResponder
{
    if (tableHeader) {
        [tableHeader.mainSearchBar resignFirstResponder];
    }
    if (visitTableHeader) {
        [visitTableHeader.mainSearchBar resignFirstResponder];
    }
}

- (void)showNavTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
//    [titleView setBackgroundColor:[UIColor redColor]];
    titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(2.5, 7, 180, 33);
    [titleButton addTarget:self action:@selector(navTitleBarClick) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTitle:[NSString stringWithFormat:@"%@",self.selectedDepartment.deptname] forState:UIControlStateNormal];
//    titleButton.backgroundColor = [UIColor greenColor];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleButton setTitleColor:rgbaColor(0.f, 122.f, 255.f, 1.f) forState:UIControlStateNormal];
    [titleView addSubview:titleButton];
    
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 30, 180, 13)];
    [titleView addSubview:navTitleLabel];
//    titleLabel.text = @"2014年10月11日至2014年11月30日";
//    navTitleLabel.backgroundColor = [UIColor yellowColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.font = [UIFont systemFontOfSize:11.f];
    navTitleLabel.textColor = [UIColor lightGrayColor];
    navTitleLabel.text = timeString;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
    UIImageView *markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(titleButton.titleLabel.frame.origin.x+titleButton.titleLabel.frame.size.width, 16, 6, 6)];
    markImageView.image = [UIImage imageNamed:@"pull-down.png"];
    [titleButton addSubview:markImageView];
}

- (void)sendRequestGetVisitDataWithBeginDate:(NSString *)beginDate endDate:(NSString *)endDate
{
    [self startLoading];
    DepartmentsService *service = [[DepartmentsService alloc] init];
    [service getDepartmentEventChartWithDepartmentId:self.selectedDepartment.deptId beginTime:beginDate endTime:endDate checkType:CHECK_TYPE_VISIT];
}

- (void)sendRequestGetAttendanceDataWithBeginDate:(NSString *)beginDate endDate:(NSString *)endDate
{
    [self startLoading];
    DepartmentsService *service = [[DepartmentsService alloc] init];
    [service getDepartmentEventChartWithDepartmentId:self.selectedDepartment.deptId beginTime:beginDate endTime:endDate checkType:CHECK_TYPE_ATTENDANCE];
}

- (void)getChartVisitDataComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]||[[self doResponse:notification.userInfo] isKindOfClass:[NSArray class]]) {
        constChartArray = [self doResponse:notification.userInfo];
//        showChartArray = [constChartArray mutableCopy];
//        [mainTableView reloadData];
        currentSearchDBColumn?[self searchDataWithDBColumn:currentSearchDBColumn]:[self searchAllData];
    }
    [self hideSegView];
    fromTimeSelectorCtrl = NO;
}

- (void)getChartAttendanceDataComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]||[[self doResponse:notification.userInfo] isKindOfClass:[NSArray class]]) {
        constChartArray = [self doResponse:notification.userInfo];
//        showChartArray = [constChartArray mutableCopy];
//        [mainTableView reloadData];
        currentSearchDBColumn?[self searchDataWithDBColumn:currentSearchDBColumn]:[self searchAllData];
    }
    [self hideSegView];
    fromTimeSelectorCtrl = NO;
}


- (void)hideSegView
{
    if (segView) {
        if (segView.onWindow) {
            [self removeSegViewInAnimation];
            mainTableView.userInteractionEnabled = YES;
        }
    }
}
#pragma mark -
#pragma mark 界面处理
- (void)initTabListViewController
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"外访" style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self showNavTitle];
}

- (TableListCell *)setAttenDanceCellValueWithTabelView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    TableListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [TableListCell loadFromNib];
    }
    NSDictionary *chartDataDic = showChartArray[indexPath.row];
    cell.nameLabel.text = chartDataDic[@"f2"];
    cell.lateLabel.text = chartDataDic[@"f6"];
    cell.earlyOutLabel.text = chartDataDic[@"f7"];
    cell.absenteeismLabel.text = chartDataDic[@"f8"];
    cell.noSignOutLabel.text = chartDataDic[@"f9"];
    cell.visitNumLabel.text = chartDataDic[@"f10"];
    cell.userId = chartDataDic[@"f1"];
    return cell;
}

- (VisitTableListCell *)setVisitCellValueWithTabelView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VisitTableListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [VisitTableListCell loadFromNib];
    }
    NSDictionary *chartDataDic = showChartArray[indexPath.row];
    cell.nameLabel.text = chartDataDic[@"f2"];
    cell.visitLabel.text = chartDataDic[@"f6"];
    cell.signInLabel.text = chartDataDic[@"f7"];
    cell.signOutLabel.text = chartDataDic[@"f8"];
    cell.userId = chartDataDic[@"f1"];
    return cell;
}

#pragma mark -通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChartAttendanceDataComplete:) name:GET_DEPARTMENT_ATTENDANCECHART_MONTH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChartVisitDataComplete:) name:GET_DEPARTMENT_VISITCHART_MONTH_NOTIFICATION object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
