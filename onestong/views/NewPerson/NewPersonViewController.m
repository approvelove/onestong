//
//  NewPersonViewController.m
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "NewPersonViewController.h"
#import "GraphicHelper.h"
#import "NewDepartmentCell.h"
#import "CDUser.h"
#import "VerifyHelper.h"
#import "DepartmentListViewController.h"
#import "CDDepartment.h"
#import "UsersService.h"
#import "CDDepartmentDAO.h"
#import "DepartmentListViewController.h"
#import "OSTButton.h"
#import "NewDepartmentCell.h"

//static const float DELTA_Y = 15;

@interface NewPersonViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet OSTButton *selectDepartmentButton;
    __weak IBOutlet UILabel *chartAuthLabel;
    __weak IBOutlet UILabel *menageDepartmentAuthLabel;
    
    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UIView *formView;
    
    __weak IBOutlet UITextField *emailTxT;
    __weak IBOutlet UITextField *nameTxT;
    __weak IBOutlet UITextField *companyTxT;
    __weak IBOutlet UITextField *positionTxT;
    __weak IBOutlet UITextField *phoneNumTxT;
    __weak IBOutlet UISwitch *departmentAndPersonPermissionSwitch;
    __weak IBOutlet UISwitch *needSignInPermissionSwitch;
    __weak IBOutlet UISwitch *checkReportPermissionSwitch;
    
    __weak IBOutlet UITableView *checkChartTable;
    __weak IBOutlet UITableView *checkDepartmentTable;
    //要填写的菜单
    
    NSLayoutConstraint *tableHeight;
    CDDepartment *currentSelectedDepartment;
    
    IBOutlet NSLayoutConstraint *chartAuthTop;
    IBOutlet NSLayoutConstraint *menagementDepartmentAuthTop;
    
    IBOutlet NSLayoutConstraint *chartTableHeight;
    IBOutlet NSLayoutConstraint *menagementDepartmentTableHeight;

    NSInteger chartTableRowNum;
    NSInteger departmentTableRowNum;
    
    NSMutableArray *selectChartAuthOrgAry;
    NSMutableArray *selectDepartmentAuthOrgAry;
    
    NewDepartmentCell *selectedCell;
    
    UITableView *selectedTableView;
    BOOL selectedButtonClick;
}
@end

@implementation NewPersonViewController
@synthesize isUpdate,user,superDepartment,needFindDepartmentById,needFindPersonById,constFatherDepartmentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isUpdate = NO;
        self.needFindPersonById = NO;
        self.needFindDepartmentById = NO;
        selectedButtonClick = NO;
    }
    return self;
}

#pragma mark -
#pragma mark  系统操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNewPersonViewController];
    [self registNotification];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (CURRENT_VERSION<7) {
        mainScrollView.contentOffset = CGPointMake(0, 0);
    }
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
#pragma mark  事件处理

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    if (sender == needSignInPermissionSwitch) {
        return;
    }
    UsersService *service = [[UsersService alloc] init];
    UsersModel *model = [service getCurrentUser];
    if ([model.userId isEqualToString:self.user.userId]) {
        sender.on = !sender.on;
        [self showAlertwithTitle:@"您无法修改自己的权限"];
        return;
    }
    if (sender == departmentAndPersonPermissionSwitch) {
        sender.on?[self showAuthButtonInAnnWithTableView:checkDepartmentTable]:[self hideAuthButtonInAnnWithTableView:checkDepartmentTable];
        sender.on?(menagementDepartmentTableHeight.constant = 100):(menagementDepartmentTableHeight.constant = 0);
    }
    else
    {
        sender.on?[self showAuthButtonInAnnWithTableView:checkChartTable]:[self hideAuthButtonInAnnWithTableView:checkChartTable];
        sender.on?(chartTableHeight.constant = 100):(chartTableHeight.constant = 0);
    }
}

- (void)newPersonCompleteButtonClick
{
    if (self.isUpdate) {
        [self editUserInfoCompleteButtonClick];
    }
    else
    {
        [self createUserInfoCompleteButtonClick];
    }
}

- (IBAction)selectDepartmentButtonClick:(id)sender
{
    selectedButtonClick = YES;
    if (self.isUpdate) {
        [self enterDepartmentListInEdit];
    }
    else
    {
        [self enterDepartmentListInCreate];
    }
}
#pragma mark -
#pragma mark  逻辑处理

- (void)refreshTableData
{
    if (selectedTableView == checkChartTable) {
        [selectChartAuthOrgAry removeAllObjects];
        for (NewDepartmentCell *cell in [selectedTableView visibleCells]) {
            if (cell.department) {
                [selectChartAuthOrgAry addObject:cell.department];
            }
        }
    }
    else
    {
        [selectDepartmentAuthOrgAry removeAllObjects];
        for (NewDepartmentCell *cell in [selectedTableView visibleCells]) {
            if (cell.department) {
                [selectDepartmentAuthOrgAry addObject:cell.department];
            }
        }
    }
}

- (void)selectDepartmentInNewPersonOver:(NSNotification *)notification
{
    CDDepartment *tempDept = notification.userInfo[@"resultData"];
    if (selectedButtonClick) {
        selectDepartmentButton.department = tempDept;
        [selectDepartmentButton setTitle:tempDept.deptname forState:UIControlStateNormal];
        selectedButtonClick = NO;
        return;
    }
    for (NewDepartmentCell *cell in [selectedTableView visibleCells]) {
        if (![cell.department.deptId isEqualToString:tempDept.deptId]) {
            continue;
        }
        else
            return;
    }
    if (selectedCell) {
        [selectedCell.selectionButton setTitle:tempDept.deptname forState:UIControlStateNormal];
        selectedCell.department = tempDept;
        selectedCell.selectionButton.department = tempDept;
        [self refreshTableData];
    }
}

- (BOOL)isEmptyMustCompleteInfo
{
    if ([VerifyHelper isEmpty:emailTxT.text]) {
        [self showAlertwithTitle:@"邮箱地址必填"];
        return YES;
    }
    
    if (!currentSelectedDepartment) {
        [self showAlertwithTitle:@"请选择一个部门"];
        return YES;
    }
    
    if ([VerifyHelper isEmpty:nameTxT.text]) {
        [self showAlertwithTitle:@"请填写姓名"];
        return YES;
    }
    
    if ([VerifyHelper isEmpty:phoneNumTxT.text]) {
        [self showAlertwithTitle:@"请填写电话号码"];
        return YES;
    }
    
    NSString * regex = @"(^[\\d]{11}$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:phoneNumTxT.text];
    if (!isMatch) {
        [self showAlertwithTitle:@"您填写的电话号码不正确"];
        return YES;
    }
    return NO;
}

- (void)manageUserInfoComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)editUserInfoCompleteButtonClick
{
    if ([self isEmptyMustCompleteInfo]) {
        return;
    }
    [self startLoading:@"正在更新用户信息..."];
    nameTxT.text = [VerifyHelper isEmpty:nameTxT.text]?@"":nameTxT.text;
    companyTxT.text = [VerifyHelper isEmpty:companyTxT.text]?@"":companyTxT.text;
    positionTxT.text = [VerifyHelper isEmpty:positionTxT.text]?@"":positionTxT.text;
    phoneNumTxT.text = [VerifyHelper isEmpty:phoneNumTxT.text]?@"":phoneNumTxT.text;
    
    UsersService *service = [[UsersService alloc] init];
    UsersModel *model = [[UsersModel alloc] init];
    model.userId = self.user.userId;
    model.email = emailTxT.text;
    model.username = nameTxT.text;
    model.companyName = companyTxT.text;
    model.companyPosition = positionTxT.text;
    model.phone = phoneNumTxT.text;
    model.department.modelId= selectDepartmentButton.department?selectDepartmentButton.department.deptId:@"";
    model.department.modelName = selectDepartmentButton.department?selectDepartmentButton.department.deptname:@"";
    model.companyDepartment = model.department.modelName;
    model.needSignIn = needSignInPermissionSwitch.on?@1:@0;
    NSMutableString *mutDepartmentStr = [@"" mutableCopy];
    if (departmentAndPersonPermissionSwitch.on) {
        for (NewDepartmentCell *cell in [checkDepartmentTable visibleCells]) {
            if (cell.department) {
                [mutDepartmentStr appendString:[NSString stringWithFormat:@",%@",cell.department.deptId]];
            }
        }
        [mutDepartmentStr appendString:@","];
        model.manageDepartmentsAuth = mutDepartmentStr;
    }
    else
    {
        model.manageDepartmentsAuth = @"";
    }
    model.manageSubDepartmentsAuth = @"";
    
    NSMutableString *mutChartStr = [@"" mutableCopy];
    if (checkReportPermissionSwitch.on) {
        for (NewDepartmentCell *cell in [checkChartTable visibleCells]) {
            if (cell.department) {
                [mutChartStr appendString:[NSString stringWithFormat:@",%@",cell.department.deptId]];
            }
        }
        [mutChartStr appendString:@","];
        model.chartAuth = mutChartStr;
    }
    else
    {
        model.chartAuth = @"";
    }
    
    [service ManageUserInfo:model];
}

- (void)createUserInfoCompleteButtonClick
{
    if ([self isEmptyMustCompleteInfo]) {
        return;
    }
    [self startLoading:@"正在创建新用户..."];
    nameTxT.text = [VerifyHelper isEmpty:nameTxT.text]?@"":nameTxT.text;
    companyTxT.text = [VerifyHelper isEmpty:companyTxT.text]?@"":companyTxT.text;
    positionTxT.text = [VerifyHelper isEmpty:positionTxT.text]?@"":positionTxT.text;
    phoneNumTxT.text = [VerifyHelper isEmpty:phoneNumTxT.text]?@"":phoneNumTxT.text;
    
    UsersService *service = [[UsersService alloc] init];
    UsersModel *model = [[UsersModel alloc] init];
    model.email = emailTxT.text;
    model.username = nameTxT.text;
    model.companyName = companyTxT.text;
    model.companyPosition = positionTxT.text;
    model.phone = phoneNumTxT.text;
    model.department.modelId= selectDepartmentButton.department?selectDepartmentButton.department.deptId:@"";
    model.department.modelName = selectDepartmentButton.department?selectDepartmentButton.department.deptname:@"";
    model.companyDepartment = model.department.modelName;
    model.needSignIn = needSignInPermissionSwitch.on?@1:@0;
    NSMutableString *mutDepartmentStr = [@"" mutableCopy];
    if (departmentAndPersonPermissionSwitch.on) {
        for (NewDepartmentCell *cell in [checkDepartmentTable visibleCells]) {
            if (cell.department) {
                [mutDepartmentStr appendString:[NSString stringWithFormat:@",%@",cell.department.deptId]];
            }
        }
        [mutDepartmentStr appendString:@","];
        model.manageDepartmentsAuth = mutDepartmentStr;
    }
    else
    {
        model.manageDepartmentsAuth = @"";
    }
    model.manageSubDepartmentsAuth = @"";
    
    NSMutableString *mutChartStr = [@"" mutableCopy];
    if (checkReportPermissionSwitch.on) {
        for (NewDepartmentCell *cell in [checkChartTable visibleCells]) {
            if (cell.department) {
                [mutChartStr appendString:[NSString stringWithFormat:@",%@",cell.department.deptId]];
            }
        }
        [mutChartStr appendString:@","];
        model.chartAuth = mutChartStr;
    }
    else
    {
        model.chartAuth = @"";
    }
    [service addUserInfo:model];
}


- (void)enterDepartmentListInEdit
{
    DepartmentListViewController *departmentCtrl = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    if (!selectDepartmentButton.department) {
        departmentCtrl.departmentId = self.user.departmentId;
    }
    else
    {
        departmentCtrl.departmentId = selectDepartmentButton.department.deptId;
    }
    departmentCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
    [self presentViewController:departmentCtrl animated:YES completion:nil];
}

- (void)enterDepartmentListInCreate
{
    DepartmentListViewController *departmentCtrl = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    departmentCtrl.departmentId = self.superDepartment.deptId;
    departmentCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
    [self presentViewController:departmentCtrl animated:YES completion:nil];
}

- (void)createUserComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark  界面处理
- (void)hideAuthButtonInAnnWithTableView:(UITableView *)tableView
{
    [UIView animateWithDuration:0.2f animations:^{
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 0);
    }];
    tableView.hidden = YES;
}

- (void)showAuthButtonInAnnWithTableView:(UITableView *)tableView
{
    [UIView animateWithDuration:0.2f animations:^{
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 100);
    }];
    if (tableView == checkChartTable) {
        [selectChartAuthOrgAry removeAllObjects];
        chartTableRowNum = 2;
    }
    else
    {
        [selectDepartmentAuthOrgAry removeAllObjects];
        departmentTableRowNum = 2;
    }
    tableView.hidden = NO;
    [tableView reloadData];
}

- (void)initNewPersonViewController
{
    [selectDepartmentButton setBackgroundImage:[GraphicHelper convertColorToImage:[UIColor grayColor]] forState:UIControlStateHighlighted];
    [self addCompleteButton];
    
    chartTableRowNum = 2;
    departmentTableRowNum = 2;
    selectChartAuthOrgAry = [@[] mutableCopy];
    selectDepartmentAuthOrgAry = [@[] mutableCopy];
    
    checkDepartmentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [checkDepartmentTable setEditing:YES animated:YES];
    checkChartTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [checkChartTable setEditing:YES animated:YES];
    
    
    [self registFormScrollView:mainScrollView];
    if (self.isUpdate) {
        //编辑
        [self initEditPersonViewController];
    }
    else
    {
        [self initCreatePersonViewController];
    }
}

- (void)initEditPersonViewController
{
    self.navigationItem.title = self.user.username;
    emailTxT.text = self.user.email;
    emailTxT.userInteractionEnabled = NO;
    nameTxT.text = self.user.username;
    companyTxT.text = self.user.companyName;
    positionTxT.text = self.user.companyPosition;
    phoneNumTxT.text = self.user.phone;
    CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
    currentSelectedDepartment = [deptDAO findById:self.user.departmentId];
    selectDepartmentButton.department = currentSelectedDepartment;
    [selectDepartmentButton setTitle:selectDepartmentButton.department.deptname forState:UIControlStateNormal];
    
    if (![VerifyHelper isEmpty:self.user.departmentName]) {
        [selectDepartmentButton setTitle:self.user.departmentName forState:UIControlStateNormal];
    }
    if (![self.user.ca isEqualToString:@""]) { //无
        checkReportPermissionSwitch.on = YES;
        [self showAuthButtonInAnnWithTableView:checkChartTable];
        NSArray *chartAuthTemp = [self.user.ca componentsSeparatedByString:@","];
        for (int i =0; i<chartAuthTemp.count; i++) {
            NSString *tempId = chartAuthTemp[i];
            if (![VerifyHelper isEmpty:tempId]) {
                CDDepartment *dept = [[[CDDepartmentDAO alloc] init] findById:tempId];
                if (dept) {
                    [selectChartAuthOrgAry addObject:dept];
                }
            }
        }
        chartTableRowNum = selectChartAuthOrgAry.count+1;
        chartTableHeight.constant = chartTableRowNum*50;
        [checkChartTable reloadData];
    }
    else
    {
        [self hideAuthButtonInAnnWithTableView:checkChartTable];
        chartTableHeight.constant = 0;
    }
    
    if (![VerifyHelper isEmpty:self.user.da]) {
        departmentAndPersonPermissionSwitch.on = YES;
        [self showAuthButtonInAnnWithTableView:checkDepartmentTable];
        NSArray *departmentAuthTemp = [self.user.da componentsSeparatedByString:@","];
        for (int i =0; i<departmentAuthTemp.count; i++) {
            NSString *tempId = departmentAuthTemp[i];
            if (![VerifyHelper isEmpty:tempId]) {
                CDDepartment *dept = [[[CDDepartmentDAO alloc] init] findById:tempId];
                if (dept) {
                    [selectDepartmentAuthOrgAry addObject:dept];
                }
            }
        }
        departmentTableRowNum = selectDepartmentAuthOrgAry.count+1;
        menagementDepartmentTableHeight.constant = departmentTableRowNum*50;
        [checkDepartmentTable reloadData];
    }
    else
    {
        [self hideAuthButtonInAnnWithTableView:checkDepartmentTable];
        menagementDepartmentTableHeight.constant = 0;
    }
    
    if ([self.user.needSignIn isEqualToNumber:[NSNumber numberWithInt:1]]) {
        needSignInPermissionSwitch.on = YES;
    }
    else
    {
        needSignInPermissionSwitch.on = NO;
    }
}

- (void)initCreatePersonViewController
{
    self.navigationItem.title = @"新建成员";
    currentSelectedDepartment = self.superDepartment;
    selectDepartmentButton.department = currentSelectedDepartment;
    if (![VerifyHelper isEmpty:self.superDepartment.deptname]) {
        [selectDepartmentButton setTitle:self.superDepartment.deptname forState:UIControlStateNormal];
    }
    [self hideAuthButtonInAnnWithTableView:checkDepartmentTable];
    [self hideAuthButtonInAnnWithTableView:checkChartTable];
    chartTableHeight.constant = 0;
    menagementDepartmentTableHeight.constant = 0;
}

-(void)addCompleteButton
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(newPersonCompleteButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark -
#pragma mark 代理

- (void)showAddChartAuthToDepartment:(NewDepartmentCell *)cell
{
    cell.vLine.hidden = YES;
    cell.titleLabel.text = @"添加部门";
    cell.selectionButton.userInteractionEnabled = NO;
    cell.bottomLine.hidden = YES;
}

- (void)showAddDepartmentAuthOrg:(NewDepartmentCell *)cell
{
    cell.vLine.hidden = YES;
    cell.titleLabel.text = @"添加部门";
    cell.selectionButton.userInteractionEnabled = NO;
    cell.bottomLine.hidden = YES;
}

- (void)showDeleteChartAuthDepartment:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.titleLabel.text = @"管理部门";
    cell.vLine.hidden = NO;
}

- (void)showDeleteDepartmentAuthOrg:(NewDepartmentCell *)cell
{
    cell.titleLabel.text = @"管理部门";
    cell.vLine.hidden = NO;
}

- (void)cellSelectedChartAuthDepartmentWithButton:(OSTButton *)sender
{
    DepartmentListViewController *departmentVC = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    if (sender.department) {
        departmentVC.departmentId = sender.department.deptId; //已经选过的
    }
    for (NewDepartmentCell *cell in [checkChartTable visibleCells]) {
        CGPoint location = [checkChartTable convertPoint:sender.frame.origin fromView:sender];
        CGRect rect = [checkChartTable  convertRect:cell.frame toView:checkChartTable];
        if (CGRectContainsPoint(rect, location)) {
            selectedCell = cell;
            selectedTableView = checkChartTable;
        }
    }
    departmentVC.constFatherDepartmentId = self.constFatherDepartmentId;
    [self presentViewController:departmentVC animated:YES completion:nil];
}

- (void)cellSelectedDepartmentAuthWithButton:(OSTButton *)sender
{
    DepartmentListViewController *departmentVC = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    if (sender.department) {
        departmentVC.departmentId = sender.department.deptId; //已经选过的
    }
    for (NewDepartmentCell *cell in [checkDepartmentTable visibleCells]) {
        CGPoint location = [checkDepartmentTable convertPoint:sender.frame.origin fromView:sender];
        CGRect rect = [checkDepartmentTable  convertRect:cell.frame toView:checkDepartmentTable];
        if (CGRectContainsPoint(rect, location)) {
            selectedCell = cell;
            selectedTableView = checkDepartmentTable;
        }
    }
    departmentVC.constFatherDepartmentId = self.constFatherDepartmentId;
    [self presentViewController:departmentVC animated:YES completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    mainScrollView.scrollEnabled = YES;
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    for (UITextField *txtField in [formView subviews]) {
        if ([txtField isMemberOfClass:[UITextField class]]) {
            [txtField resignFirstResponder];
        }
    }
}

#pragma mark - tableview 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == checkChartTable) {
        return chartTableRowNum;
    }
    else
    {
        return departmentTableRowNum;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    NewDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [NewDepartmentCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionButton.tag = indexPath.row;
    
    //区分两个不同的tableview
    if (tableView == checkChartTable) {
        if (chartTableRowNum-1 == indexPath.row) {
            [self showAddChartAuthToDepartment:cell];
        }
        else
        {
            [self showDeleteChartAuthDepartment:cell andIndexPath:indexPath];
            if (selectChartAuthOrgAry&&indexPath.row<[selectChartAuthOrgAry count]) {
                CDDepartment *tempDepartment = selectChartAuthOrgAry[indexPath.row];
                cell.department = tempDepartment;
                [cell.selectionButton setTitle:tempDepartment.deptname forState:UIControlStateNormal];
            }
            else
            {
                [cell.selectionButton setTitle:@"请选择" forState:UIControlStateNormal];
            }
            cell.selectionButton.department = cell.department;
            [cell.selectionButton addTarget:self action:@selector(cellSelectedChartAuthDepartmentWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        if (departmentTableRowNum-1 == indexPath.row) {
            [self showAddDepartmentAuthOrg:cell];
        }
        else
        {
            [self showDeleteDepartmentAuthOrg:cell];
            if (selectDepartmentAuthOrgAry&&indexPath.row<[selectDepartmentAuthOrgAry count]) {
                CDDepartment *tempDept = selectDepartmentAuthOrgAry[indexPath.row];
                cell.department = tempDept;
                cell.selectionButton.department = tempDept;
                [cell.selectionButton setTitle:tempDept.deptname forState:UIControlStateNormal];
            }
            else
            {
                [cell.selectionButton setTitle:@"请选择" forState:UIControlStateNormal];
            }
            [cell.selectionButton addTarget:self action:@selector(cellSelectedDepartmentAuthWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == checkChartTable) {
        if (indexPath.row == chartTableRowNum -1) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    else
    {
        if (indexPath.row == departmentTableRowNum -1) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewDepartmentCell *cell = (NewDepartmentCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView == checkChartTable) {
        [self changeChartAuthTableViewWith:cell andIndexPath:indexPath];
    }
    else
    {
        [self changeDepartmentAuthTableViewWith:cell andIndexPath:indexPath];
    }
}

- (void)changeChartAuthTableViewWith:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if (cell.editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *tempAry = [selectChartAuthOrgAry copy];
        [selectChartAuthOrgAry removeAllObjects];
        for (int i =0; i<[tempAry count]; i++) {
            CDDepartment *obj = tempAry[i];
            if (![obj.deptId isEqualToString:cell.department.deptId]) {
                if (obj) {
                    [selectChartAuthOrgAry addObject:obj];
                }
            }
        }
        chartTableRowNum--;
        chartTableHeight.constant = chartTableHeight.constant-50;
        [checkChartTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [checkChartTable reloadData];
    }
    else
    {
        chartTableRowNum++;
        chartTableHeight.constant = chartTableHeight.constant+50;
        [checkChartTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [checkChartTable reloadData];
    }
}

- (void)changeDepartmentAuthTableViewWith:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if (cell.editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *tempAry = [selectDepartmentAuthOrgAry copy];
        [selectDepartmentAuthOrgAry removeAllObjects];
        for (int i =0; i<[tempAry count]; i++) {
            CDDepartment *obj = tempAry[i];
            if (![obj.deptId isEqualToString:cell.department.deptId]) {
                if (obj) {
                    [selectDepartmentAuthOrgAry addObject:obj];
                }
            }
        }
        departmentTableRowNum--;
        menagementDepartmentTableHeight.constant = menagementDepartmentTableHeight.constant-50;
        [checkDepartmentTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [checkDepartmentTable reloadData];
    }
    else
    {
        departmentTableRowNum++;
        menagementDepartmentTableHeight.constant = menagementDepartmentTableHeight.constant+50;
        [checkDepartmentTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [checkDepartmentTable reloadData];
    }
}
#pragma mark -
#pragma mark  通知管理
- (void)registNotification
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDepartmentComplete:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manageUserInfoComplete:) name:MANAGE_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createUserComplete:) name:ADD_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDepartmentInNewPersonOver:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MANAGE_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_USER_INFO_NOTIFICATION object:nil];
}
@end
