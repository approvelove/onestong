//
//  SettingViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SettingViewController.h"
#import "SDImageCache.h"
#import <MessageUI/MessageUI.h>
#import "DataUpdateService.h"

@interface SettingViewController ()<UITableViewDataSource,UIActionSheetDelegate,UITableViewDelegate,MFMailComposeViewControllerDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    NSDictionary *settingFunction;
    NSDictionary *functionNameDiction;
}
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registNotification];
    [self initSettingViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self freeNotification];
}
#pragma mark -
#pragma mark 界面操作

- (void)showActionSheetOnWindow
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您真的要清除缓存内容么？此操作不可撤销。" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"清除缓存内容",nil];
    [actionSheet showInView:self.view];
}

- (void)initSettingViewController
{
    self.navigationItem.title = @"设置";
    if (settingFunction == nil) {
        settingFunction = @{@"设置":@[@"清理缓存"],@"其它":@[@"反馈",@"数据同步"]};
    }
    if (functionNameDiction == nil) {
        functionNameDiction = @{@"设置":@[@"clearCacheDataClick"],@"其它":@[@"feedbackButtonClick",@"dataUpdateButtonClick"]};
    }
}

#pragma mark -
#pragma mark 界面逻辑处理

-(NSString *)getMemorySize
{
    long size = [[SDImageCache sharedImageCache]getSize];
    NSLog(@"%ld", size);
    NSString *strSize = @"0 byte";
    if (size>1024*1024) {
        strSize = [NSString stringWithFormat:@"%.2f M", size / 1024.0 / 1024];
    }else if (size>1024) {
        strSize = [NSString stringWithFormat:@"%.2f K", size / 1024.0];
    }else{
        strSize = [NSString stringWithFormat:@"%ld byte", size];
    }
    return strSize;
}

-(void)clearCacheData
{
    [[SDImageCache sharedImageCache]clearDisk];
    [mainTableView reloadData];
}

- (void)sendEmailBack
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    picker.mailComposeDelegate = self;
    [picker setSubject:@""];
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"onestong@mc2.cn"];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)dataUpdate
{
    DataUpdateService *dataUpdateService = [[DataUpdateService alloc]init];
    [dataUpdateService updateUsersData];
    [self startLoading:@"正在更新用户数据"];
}

#pragma mark -
#pragma mark 界面事件处理

- (void)clearCacheDataClick
{
    [self showActionSheetOnWindow];
}

- (void)feedbackButtonClick
{
    NSLog(@"反馈");
    [self sendEmailBack];
}

-(void)dataUpdateButtonClick
{
    NSLog(@"数据同步");
    [self dataUpdate];
}

#pragma mark -
#pragma mark 界面数据处理

-(void)departmentsUpdateComplete:(NSNotification *)notification
{
    [self stopLoading];
}

-(void)usersUpdateComplete:(NSNotification *)notification
{
    [self stopLoading];
    DataUpdateService *dataUpdateService = [[DataUpdateService alloc]init];
    [dataUpdateService updateDepartmentsData];
    [self startLoading:@"正在更新部门数据"];
}

#pragma mark -
#pragma mark 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self clearCacheData];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[settingFunction allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (settingFunction) {
        return [settingFunction allKeys][section];
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (settingFunction) {
        return [settingFunction[[settingFunction allKeys][section]] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellone"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString * labelText = settingFunction[[settingFunction allKeys][indexPath.section]][indexPath.row];
    cell.textLabel.text = labelText;
    if ([labelText isEqualToString:@"清理缓存"]) {
        cell.detailTextLabel.text = [self getMemorySize];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:NSSelectorFromString(functionNameDiction[[functionNameDiction allKeys][indexPath.section]][indexPath.row])]) {
        [self performSelector:NSSelectorFromString(functionNameDiction[[functionNameDiction allKeys][indexPath.section]][indexPath.row]) withObject:nil afterDelay:0.f];
    }
}

#pragma mark -
#pragma mark 视图通知管理
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentsUpdateComplete:) name:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersUpdateComplete:) name:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
}

-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DEPARTMENTS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USERS_DATA_UPDATE_COMPLETE_NOTIFICATION object:nil];
}
@end
