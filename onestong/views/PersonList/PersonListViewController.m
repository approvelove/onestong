//
//  PersonListViewController.m
//  onestong
//
//  Created by 李健 on 14-5-27.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "PersonListViewController.h"
#import "CDUserDAO.h"
#import "CDUser.h"

@interface PersonListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    NSMutableArray *userAry;
    NSIndexPath *selectedIndexPath;
    UISearchBar *mainSearchBar;
    NSMutableArray *constUserAry;
}
@end

@implementation PersonListViewController
@synthesize userId,ownerUserId,constFatherDepartmentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark 系统界面

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initDepartCtrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 事件处理

- (IBAction)cancelUserInfoViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_USER_IN_LIST_CANCEL object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeButtonClick
{
    if (!selectedIndexPath) {
        [self showAlertwithTitle:@"请选择一个部门"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_USER_IN_LIST object:nil userInfo:@{@"resultData":userAry[selectedIndexPath.row]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark 逻辑处理
- (void)loadDepartmentData
{
    CDUserDAO *userDAO = [[CDUserDAO alloc] init];
    userAry = [[userDAO findAll] mutableCopy];
    for (int i=0; i<[userAry count]; i++) {
        CDUser *temp = userAry[i];
        if ([temp.userId isEqualToString:self.constFatherDepartmentId]) {
            [userAry removeObject:temp];
        }
    }
    constUserAry = [userAry mutableCopy];
    [mainTableView reloadData];
}

- (void)resignResponder
{
    if (mainSearchBar) {
        [mainSearchBar resignFirstResponder];
    }
}

- (void)searchStringWithString:(NSString *)searchText
{
    if (!constUserAry) {
        return;
    }
    if (userAry) {
        [userAry removeAllObjects];
        userAry = nil;
    }
    if (!searchText||[searchText isEqualToString:@""]) {
        userAry = [constUserAry mutableCopy];
    }
    else
    {
        userAry = [@[] mutableCopy];
        for (int i = 0; i<[constUserAry count];i++) {
            NSLog(@"i = %d",i);
            CDUser *obj = constUserAry[i];
            NSRange tempRangeA = [obj.username rangeOfString:searchText];
            if (tempRangeA.length>0) {
                [userAry addObject:obj];
                continue;
            }
            NSRange tempRangeB = [obj.departmentName rangeOfString:searchText];
            if (tempRangeB.length>0) {
                [userAry addObject:obj];
                continue;
            }
            NSRange tempRangeC = [obj.email rangeOfString:searchText];
            if (tempRangeC.length>0) {
                [userAry addObject:obj];
            }
        }
    }
    [mainTableView reloadData];
}
#pragma mark -
#pragma mark 界面处理
- (void)initDepartCtrl
{
    userAry = [NSMutableArray array];
    [self loadDepartmentData];
}

- (UISearchBar *)addSearchBar
{
    if (!mainSearchBar) {
        mainSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44.f)];
        mainSearchBar.delegate = self;
    }
    mainSearchBar.barStyle = UIBarStyleDefault;
    
    if (CURRENT_VERSION>=7) {
        mainSearchBar.searchBarStyle = UISearchBarStyleProminent;
        NSMutableString *holder = [NSMutableString stringWithString:@"搜索                                                          "];
        mainSearchBar.placeholder =holder;
    }
    else
    {
        mainSearchBar.placeholder = @"搜索";
    }
    return mainSearchBar;
}
#pragma mark -
#pragma mark 代理

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [headerView addSubview:[self addSearchBar]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userAry count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellone"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CDUser *tempUser = userAry[indexPath.row];
    if (!selectedIndexPath && [self.userId isEqual:tempUser.userId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedIndexPath = indexPath;
    }
    if (selectedIndexPath && selectedIndexPath.row==indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = tempUser.username;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    NSString *tempDetailStr = [NSString stringWithFormat:@"%@   邮箱:%@",tempUser.departmentName,tempUser.email];
    cell.detailTextLabel.text = [tempDetailStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [userAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * path = [NSIndexPath indexPathForRow:idx inSection:0];
        UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:path];
        tempCell.accessoryType = UITableViewCellAccessoryNone;
    }];
    selectedIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
#pragma mark -
#pragma mark 通知管理

@end
