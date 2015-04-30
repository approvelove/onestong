//
//  EventsBoxViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "EventsBoxViewController.h"
#import "TimeListViewController.h"
#import "OrganizeViewController.h"
#import "DepartmentOnlyViewController.h"
#import "UsersService.h"
#import "MapPathChartDepartmenListViewController.h"
#import "VerifyHelper.h"
#import "CDDepartmentDAO.h"
#import "CDUser.h"
#import "CDUserDAO.h"

static NSString *const showDeviceTraceAuth = @"9999";

@interface EventsBoxViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *eventsBoxFunction;
    __weak IBOutlet UITableView *mainTable;
    NSMutableArray *functionNameArray;
}

@end

@implementation EventsBoxViewController
@synthesize currentBox,currentUser;

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
    [self initMyProfileFunction];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 界面事件处理

- (void)myEventClick:(id)sender
{
    TimeListViewController *timeListCtrl = [[TimeListViewController alloc] initWithNibName:@"TimeListViewController" bundle:nil];
    timeListCtrl.eventType = EVENTTYPE_ATTENDANCE;
    timeListCtrl.navigationItem.title = @"考勤一览";
    if (self.currentBox == Box_Other) {
        timeListCtrl.user = self.currentUser;
    }
    else
    {
        timeListCtrl.user = nil;
    }
    [self.navigationController pushViewController:timeListCtrl animated:YES];
}

- (void)reportChartCheck:(id)sender
{
    DepartmentOnlyViewController *dovCtrl = [[DepartmentOnlyViewController alloc] initWithNibName:@"DepartmentOnlyViewController" bundle:nil];
    [self.navigationController pushViewController:dovCtrl animated:YES];
}


-(IBAction)organizeClick:(id)sender
{
    OrganizeViewController *organizeViewController = [[OrganizeViewController alloc] initWithNibName:@"OrganizeViewController" bundle:nil];
    organizeViewController.navigationItem.title = @"我的部门";
    [self.navigationController pushViewController:organizeViewController animated:YES];
}


- (void)mapPathChartClick
{
    MapPathChartDepartmenListViewController *mapPathCtrl = [[MapPathChartDepartmenListViewController alloc] initWithNibName:@"MapPathChartDepartmenListViewController" bundle:nil];
    [self.navigationController pushViewController:mapPathCtrl animated:YES];
}

 


- (void)myEventMapChartClick:(id)sender
{
    TimeListViewController *timeListCtrl = [[TimeListViewController alloc] initWithNibName:@"TimeListViewController" bundle:nil];
    timeListCtrl.eventType = EVENTTYPE_EVENT_MAPPATH;
//    timeListCtrl.navigationItem.title = @"事件";
    if (self.currentBox == Box_Other_Mapchart) {
        timeListCtrl.user = self.currentUser;
    }
    [self.navigationController pushViewController:timeListCtrl animated:YES];
}

- (void)myDeviceMapChartClick:(id)sender
{
    TimeListViewController *timeListCtrl = [[TimeListViewController alloc] initWithNibName:@"TimeListViewController" bundle:nil];
    timeListCtrl.eventType = EVENTTYPE_DEVICE_MAPPATH;
//    timeListCtrl.navigationItem.title = @"设备";
    if (self.currentBox == Box_Other_Mapchart) {
        timeListCtrl.user = self.currentUser;
    }
    [self.navigationController pushViewController:timeListCtrl animated:YES];
}
#pragma mark -
#pragma mark 界面操作
- (void)initMyProfileFunction
{
    self.navigationItem.title = @"事件箱";
    UsersService *service = [[UsersService alloc] init];
    UsersModel *model = [service getCurrentUser];
    switch (self.currentBox) {
        case Box_Other:
            if (eventsBoxFunction == nil) {
                eventsBoxFunction = [@[@"考勤",@"外访"] mutableCopy];
            }
            if (functionNameArray == nil) {
                functionNameArray = [@[@"myAttendanceClick:",@"mySignClick:"] mutableCopy];
            }
            break;
            
        case Box_owner:
            if (eventsBoxFunction == nil) {
                eventsBoxFunction = ([VerifyHelper isEmpty:model.chartAuth])?[@[@"我的事件",@"我的部门"] mutableCopy]: [@[@"我的事件",@"我的部门",@"事件报表",@"轨迹报表"] mutableCopy];
            }
            if (functionNameArray == nil) {
                functionNameArray = ([VerifyHelper isEmpty:model.chartAuth])?[@[@"myEventClick:",@"organizeClick:"]  mutableCopy]:[@[@"myEventClick:",@"organizeClick:",@"reportChartCheck:",@"mapPathChartClick"] mutableCopy];
            }
            break;
        case Box_Other_Mapchart:
            {
               if (eventsBoxFunction == nil) {
                   eventsBoxFunction = ([VerifyHelper isEmpty:model.chartAuth])?[@[] mutableCopy]:[@[@"事件轨迹"] mutableCopy];
                   //@"设备轨迹"
                   [model.manageSubDepartmentsAuth isEqualToString:showDeviceTraceAuth]?[eventsBoxFunction addObject:@"设备轨迹"]:nil;
               }
               if (functionNameArray == nil) {
                   functionNameArray = ([VerifyHelper isEmpty:model.chartAuth])?[@[] mutableCopy]:[@[@"myEventMapChartClick:"] mutableCopy];
                   [model.manageSubDepartmentsAuth isEqualToString:showDeviceTraceAuth]?[functionNameArray addObject:@"myDeviceMapChartClick:"]:nil;
               }
            }
            break;
    }
}

#pragma mark -
#pragma mark 代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (eventsBoxFunction) {
        return [eventsBoxFunction count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellone"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [eventsBoxFunction objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:NSSelectorFromString([functionNameArray objectAtIndex:indexPath.row])]) {
        [self performSelector:NSSelectorFromString([functionNameArray objectAtIndex:indexPath.row]) withObject:nil afterDelay:0.f];
    }
}
@end
