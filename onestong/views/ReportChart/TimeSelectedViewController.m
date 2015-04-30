//
//  TimeSelectedViewController.m
//  onestong
//
//  Created by 李健 on 14-6-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "TimeSelectedViewController.h"
#import "TimeHelper.h"

@interface TimeSelectedViewController ()
{
    __weak IBOutlet UIDatePicker *beginPicker;
    __weak IBOutlet UIDatePicker *endPicker;
}
@end

@implementation TimeSelectedViewController

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
    [self initializeTimeSelectedCtrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 事件处理
- (void)rightItemClick
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *startDateStr = [dateFormatter stringFromDate:beginPicker.date];
    
    NSString *endDateStr = [dateFormatter stringFromDate:endPicker.date];
    
    long long startTime = [TimeHelper convertDateToSecondTime:beginPicker.date];
    long long endTime = [TimeHelper convertDateToSecondTime:endPicker.date];
    if (startTime>endTime) {
        [self showAlertwithTitle:@"您搜索的开始时间超过了结束时间，请重新设置"];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TIME_SELECTED_OVER_NOTIFICATION object:nil userInfo:@{@"start":startDateStr,@"end":endDateStr}];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 逻辑处理


#pragma mark - 界面处理
- (void)initializeTimeSelectedCtrl
{
    [self addRightItem];
}

- (void)addRightItem
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
@end
