//
//  DepartmentListViewController.m
//  onestong
//
//  Created by 李健 on 14-5-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DepartmentListViewController.h"
#import "CDDepartmentDAO.h"
#import "CDDepartment.h"

@interface DepartmentListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    NSMutableArray *departmentAry;
    NSIndexPath *selectedIndexPath;
    __weak IBOutlet NSLayoutConstraint * constraintTop;
}
@end

@implementation DepartmentListViewController
@synthesize departmentId,ownerDepartmentId,findRange,constFatherDepartmentId;

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
    if (CURRENT_VERSION < 7) {
        constraintTop.constant = 0;
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST_CANCEL object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeButtonClick
{
    if (!selectedIndexPath) {
        [self showAlertwithTitle:@"请选择一个部门"];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil userInfo:@{@"resultData":departmentAry[selectedIndexPath.row]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark 逻辑处理
- (void)loadDepartmentData
{
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
    departmentAry = [[departmentDAO findAll] mutableCopy];
    for (int i = 0; i<[departmentAry count]; i++) {
        CDDepartment *temp = departmentAry[i];
        if ([temp.deptId isEqualToString:self.ownerDepartmentId]) {
            [departmentAry removeObject:temp];
        }
    }
    [mainTableView reloadData];
}

- (void)loadDepartmentDataById:(NSString *)deptId
{
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
    NSArray *tempAry = [departmentDAO findSubDepartmentById:deptId];
    if (tempAry) {
        departmentAry = [tempAry mutableCopy];
    }
    for (int i = 0; i<[departmentAry count]; i++) {
        CDDepartment *temp = departmentAry[i];
        if ([temp.deptId isEqualToString:self.ownerDepartmentId]) {
            [departmentAry removeObject:temp];
        }
    }
    [mainTableView reloadData];
}

#pragma mark -
#pragma mark 界面处理
- (void)initDepartCtrl
{
    departmentAry = [NSMutableArray array];
    if (self.constFatherDepartmentId && ![self.constFatherDepartmentId isEqualToString:@"1"]) {
        [self loadDepartmentDataById:self.constFatherDepartmentId];
    }
    else
    {
        [self loadDepartmentData];
    }
//    switch (findRange) {
//        case FIND_DATA_ALL:
//            [self loadDepartmentData];
//            break;
//        case FIND_DATA_BY_ID:
//            [self loadDepartmentDataById:self.ownerDepartmentId];
//            break;
//        default:
//            [self loadDepartmentData];
//            break;
//    }
    
    
}

#pragma mark -
#pragma mark 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [departmentAry count];
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
    CDDepartment *department = departmentAry[indexPath.row];
    if (!selectedIndexPath && [self.departmentId isEqual:department.deptId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedIndexPath = indexPath;
    }
    if (selectedIndexPath && selectedIndexPath.row==indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = department.deptname;
    cell.detailTextLabel.text = department.parentName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [departmentAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * path = [NSIndexPath indexPathForRow:idx inSection:0];
        UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:path];
        tempCell.accessoryType = UITableViewCellAccessoryNone;
    }];
    selectedIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}
#pragma mark -
#pragma mark 通知管理
@end
