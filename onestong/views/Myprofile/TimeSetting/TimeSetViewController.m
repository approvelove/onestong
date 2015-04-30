//
//  TimeSetViewController.m
//  onestong
//
//  Created by 李健 on 14-6-5.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "TimeSetViewController.h"
#import "TimeSetSerivce.h"
#import "TimeSetModel.h"
#import "TimeHelper.h"


@interface TimeSetViewController ()<UIAlertViewDelegate>
{
    __weak IBOutlet UIDatePicker *beginPicker;
    __weak IBOutlet UIDatePicker *endPicker;
    TimeSetModel *currentModel;
}
@end

@implementation TimeSetViewController

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
    [self initTimeSetViewController];
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

#pragma mark - 事件处理
- (void)setTimeButtonClick
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *startDateStr = [dateFormatter stringFromDate:beginPicker.date];
    currentModel.startTime = startDateStr;
    NSString *endDateStr = [dateFormatter stringFromDate:endPicker.date];
    currentModel.endTime = endDateStr;
    
    long long startTime = [TimeHelper convertDateToSecondTime:beginPicker.date];
    long long endTime = [TimeHelper convertDateToSecondTime:endPicker.date];
    
//    [self saveWorkTimeInUserDefaultsWithStartTime:startTime endTime:endTime];
    if (startTime>=endTime) {
        UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"开始时间不能大于或等于结束时间" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [tempAlert show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"工作时间设定为：%@—%@",startDateStr,endDateStr];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交", nil];
    [alert show];
}

- (void)saveWorkTimeInUserDefaultsWithStartTime:(long long)startTime endTime:(long long)endTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(startTime) forKey:@"startTime"];
    [defaults setObject:@(endTime) forKey:@"endTime"];
}
#pragma mark - 逻辑处理

- (void)setTimeOnService
{
    TimeSetSerivce *service = [[TimeSetSerivce alloc] init];
    
    [service addTimeInfoWithTimeSetModel:currentModel];
}

- (void)findTimeSetterCpmplete:(NSNotification *)notification
{
    NSArray *tempAry = [self doResponse:notification.userInfo];
    if (tempAry&&tempAry.count>0) {
        TimeSetModel *model = [tempAry lastObject];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSDate *beginDate = [dateFormatter dateFromString:model.startTime];
        beginPicker.date = beginDate;
        NSDate *endDate = [dateFormatter dateFromString:model.endTime];
        endPicker.date = endDate;
        currentModel = [[TimeSetModel alloc] init];
        currentModel.timeId = model.timeId?model.timeId:@"";
    }
    else
    {
       currentModel = [[TimeSetModel alloc] init];
       currentModel.timeId = @"";
    }
}

- (void)addTimeInfoComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        [self toast:@"时间设定成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 界面处理
- (void)initTimeSetViewController
{
    self.navigationItem.title = @"工作时间设定";
    [self registNotification];
    TimeSetSerivce *service = [[TimeSetSerivce alloc] init];
    [service findAllWorkTime];
    [self addItemRight];
}

- (void)addItemRight
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设定" style:UIBarButtonItemStylePlain target:self action:@selector(setTimeButtonClick)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - 代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self setTimeOnService];
    }
}
#pragma mark - 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findTimeSetterCpmplete:) name:NOTIFICATION_FIND_ALL_TIME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTimeInfoComplete:) name:NOTIFICATION_ADD_TIME object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FIND_ALL_TIME object:nil];
}
@end
