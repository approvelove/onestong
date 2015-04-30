//
//  NewDepartmentViewController.m
//  onestong
//
//  Created by 李健 on 14-5-21.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "NewDepartmentViewController.h"
#import "GraphicHelper.h"
#import "NewDepartmentCell.h"
#import "DepartmentListViewController.h"
#import "CDDepartment.h"
#import "CDUser.h"
#import "PersonListViewController.h"
#import "DepartmentsService.h"
#import "DepartmentsService.h"
#import "AppDelegate.h"
#import "VerifyHelper.h"
#import "CDDepartmentDAO.h"
#import "CDUserDAO.h"


static NSString *const COMPANYNAME = @"美承集团";
@interface NewDepartmentViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *addDepartmentPersonTableView;
    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UITextField *departmentNameTxT;
    __weak IBOutlet UITableView *selectSuperDepartmentTableView;
    
    NSInteger rowNumber;
    NSInteger rowNumberSuperDepartmentTableView;
    NSLayoutConstraint *tableHeight;
    NSLayoutConstraint *tableHeighe_department;
    
    CDDepartment *currentDepartment;
    CDUser *currentUser;
    
    NewDepartmentCell *selectedCell;
    
    NSMutableArray *selectedPersonAry;
    NSMutableArray *selectedSuprerDepartmentAry;
    
    CDDepartment *deletDepartment;
    CDUser *deleteUser;
}
@end

@implementation NewDepartmentViewController
@synthesize currentDepartmentADO,isUpdate,superDepartment,needFindDepartmentById,needFindPersonById,constFatherDepartmentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isUpdate = NO;
        self.needFindPersonById = NO;
        self.needFindDepartmentById = NO;
    }
    return self;
}
#pragma mark -
#pragma mark 系统方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNewDepartmentViewController];
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
#pragma mark - 事件处理
- (void)addCompleteDepartmentButtonClick
{
    if (self.isUpdate == YES) {
        [self sendRequestUpdateDepartment];
        return;
    }
    [self sendRequestAddDepartment];
}

- (void)cellSelectedSuperDepartmentWithButton:(UIButton *)sender
{
    DepartmentListViewController *departmentVC = [[DepartmentListViewController alloc] initWithNibName:@"DepartmentListViewController" bundle:nil];
    if (self.isUpdate) {  //更新
        departmentVC.ownerDepartmentId = currentDepartmentADO.deptId;  //自己的ID
    }
    if (currentDepartment) {
        departmentVC.departmentId = currentDepartment.deptId; //已经选过的
    }
    for (NewDepartmentCell *cell in [selectSuperDepartmentTableView visibleCells]) {
        CGPoint location = [selectSuperDepartmentTableView convertPoint:sender.frame.origin fromView:sender];
        CGRect rect = [selectSuperDepartmentTableView  convertRect:cell.frame toView:selectSuperDepartmentTableView];
        if (CGRectContainsPoint(rect, location)) {
            selectedCell = cell;
            if (selectedCell.department&&selectedCell.department.deptId) {
                deletDepartment = selectedCell.department;
                [self removeDepartmentInArrayWithDeptId:selectedCell.department.deptId];
            }
        }
    }
    departmentVC.constFatherDepartmentId = self.constFatherDepartmentId;
//    self.needFindDepartmentById?(departmentVC.findRange = FIND_DATA_BY_ID):(departmentVC.findRange = FIND_DATA_ALL);
    [self presentViewController:departmentVC animated:YES completion:nil];
}

- (void)cellSelectedWithButton:(UIButton *)sender
{
    PersonListViewController *personVC = [[PersonListViewController alloc] initWithNibName:@"PersonListViewController" bundle:nil];
    if (currentUser) {
        personVC.userId = currentUser.userId;
    }
    for (NewDepartmentCell *cell in [addDepartmentPersonTableView visibleCells]) {
        CGPoint location = [addDepartmentPersonTableView convertPoint:sender.frame.origin fromView:sender];
        CGRect rect = [addDepartmentPersonTableView  convertRect:cell.frame toView:addDepartmentPersonTableView];
        if (CGRectContainsPoint(rect, location)) {
            selectedCell = cell;
            if (selectedCell.user&&selectedCell.user.userId) {
                deleteUser = selectedCell.user;
                [self removePersonInArrayWithPersonId:selectedCell.user.userId];
            }
        }
    }
    [self presentViewController:personVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark 逻辑处理
- (void)removeDepartmentInArrayWithDeptId:(NSString *)deptId
{
    for (int i=0; i<[selectedSuprerDepartmentAry count]; i++) {
        CDDepartment *tempDept = selectedSuprerDepartmentAry[i];
        if ([tempDept.deptId isEqualToString:deptId]) {
            [selectedSuprerDepartmentAry removeObject:tempDept];
        }
    }
}

- (void)removePersonInArrayWithPersonId:(NSString *)personId
{
    for (int i=0; i<[selectedPersonAry count]; i++) {
        CDUser *tempUser = selectedPersonAry[i];
        if ([tempUser.userId isEqualToString:personId]) {
            [selectedPersonAry removeObject:tempUser];
        }
    }
}

- (BOOL)isEmptyMustWriteUserInfo
{
    if ([VerifyHelper isEmpty:departmentNameTxT.text]) {
        [self showAlertwithTitle:@"部门名称未填写"];
        return YES;
    }
    return NO;
}

- (void)sendRequestUpdateDepartment
{
    if ([self isEmptyMustWriteUserInfo]) {
        return;
    }
    [self startLoading:@"正在更新部门信息..."];
    DepartmentsService *dptService = [[DepartmentsService alloc] init];
    DepartmentModel *department = [[DepartmentModel alloc] init];
   
    NSMutableString *idStr = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i<[selectedSuprerDepartmentAry count]; i++) {
        CDDepartment *temp = selectedSuprerDepartmentAry[i];
        [idStr appendString:[NSString stringWithFormat:@"%@,",temp.deptId]];
    }
//    if ([idStr hasPrefix:@","]) {
//        [idStr deleteCharactersInRange:NSMakeRange(0, 1)];
//    }
    department.parentId = [NSString stringWithFormat:@",%@",idStr];
    department.departmentId = currentDepartmentADO.deptId;
    department.departmentName = departmentNameTxT.text?departmentNameTxT.text:@"";
    
    if (selectedSuprerDepartmentAry&&[selectedSuprerDepartmentAry count]>0) {
        CDDepartment *superDept = selectedSuprerDepartmentAry[0];
        if (superDept.parentName&&superDept.parentName.length>0) {
            department.parentName = [NSString stringWithFormat:@"%@-%@",superDept.parentName,superDept.deptname];
        }
        else
        {
            department.parentName = [NSString stringWithFormat:@"%@",[superDept.deptname isEqualToString:COMPANYNAME]?@"":superDept.deptname];
        }
    }
    else
    {
        department.parentName = @"";
    }
    
    NSMutableString *mutStr = [NSMutableString string];
    [selectedPersonAry enumerateObjectsUsingBlock:^(CDUser *obj, NSUInteger idx, BOOL *stop) {
        [mutStr appendFormat:@"%@,",obj.email];
    }];
//    if (mutStr.length>0) {
//        if ([mutStr hasPrefix:@","]) {
//            [mutStr deleteCharactersInRange:NSMakeRange(0, 1)];
//        }
//    }
    department.departmentOwner = [NSString stringWithFormat:@",%@",mutStr];
    [dptService updateDepartment:department];
}

- (void)sendRequestAddDepartment
{
    if ([self isEmptyMustWriteUserInfo]) {
        return;
    }
    [self startLoading:@"正在添加新部门..."];
    DepartmentsService *dptService = [[DepartmentsService alloc] init];
    DepartmentModel *departmentModel = [[DepartmentModel alloc] init];
    departmentModel.departmentName = departmentNameTxT.text;
    NSMutableString *idStr = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i<[selectedSuprerDepartmentAry count]; i++) {
        CDDepartment *temp = selectedSuprerDepartmentAry[i];
        [idStr appendString:[NSString stringWithFormat:@"%@,",temp.deptId]];
    }
//    if ([idStr hasPrefix:@","]) {
//        [idStr deleteCharactersInRange:NSMakeRange(0, 1)];
//    }
    departmentModel.parentId = [NSString stringWithFormat:@",%@",idStr];
    
    if (selectedSuprerDepartmentAry&&[selectedSuprerDepartmentAry count]>0) {
        CDDepartment *superDept = selectedSuprerDepartmentAry[0];
        if (superDept.parentName&&superDept.parentName.length>0) {
            departmentModel.parentName = [NSString stringWithFormat:@"%@-%@",superDept.parentName,superDept.deptname];
        }
        else
        {
            departmentModel.parentName = [NSString stringWithFormat:@"%@",[superDept.deptname isEqualToString:COMPANYNAME]?@"":superDept.deptname];
        }
    }
    else
    {
        departmentModel.parentName = @"";
    }
    NSMutableString *mutStr = [NSMutableString string];
    [selectedPersonAry enumerateObjectsUsingBlock:^(CDUser *obj, NSUInteger idx, BOOL *stop) {
        [mutStr appendFormat:@"%@,",obj.email];
    }];
//    if (mutStr.length>0) {
//        if ([mutStr hasPrefix:@","]) {
//            [mutStr deleteCharactersInRange:NSMakeRange(0, 1)];
//        }
//    }
    
    departmentModel.departmentOwner = [NSString stringWithFormat:@",%@",mutStr];
    [dptService addDepartment:departmentModel];
}

- (void)selectDepartmentOver:(NSNotification *)notification
{
    currentDepartment = notification.userInfo[@"resultData"];
    if ([currentDepartment.deptId isEqual:self.currentDepartmentADO.deptId]) {
        [self showAlertwithTitle:@"您不能选择自己作为上级部门"];
        return;
    }
    for (int i = 0; i<[selectedSuprerDepartmentAry count]; i++) {
        CDDepartment *temp = selectedSuprerDepartmentAry[i];
        if ([temp.deptId isEqualToString:currentDepartment.deptId]) {
            [self toast:@"您不能重复选择同一个部门"];
            return;
        }
    }
    if (selectedCell) {
        [selectedCell.selectionButton setTitle:currentDepartment.deptname forState:UIControlStateNormal];
        [selectedSuprerDepartmentAry addObject:currentDepartment];
        selectedCell.department = currentDepartment;
    }
}

- (void)selectedDepartmentCancel:(NSNotification *)notification
{
    if (deletDepartment == nil) {
        return;
    }
    if (selectedCell) {
        [selectedCell.selectionButton setTitle:deletDepartment.deptname forState:UIControlStateNormal];
        [selectedSuprerDepartmentAry addObject:deletDepartment];
        selectedCell.department = deletDepartment;
    }
    deletDepartment = nil;
}

- (void)selectUserOver:(NSNotification *)notification
{
    CDUser *noti_user = notification.userInfo[@"resultData"];
    for (int i = 0; i<[selectedPersonAry count]; i++) {
        CDUser *temp = selectedPersonAry[i];
        if ([temp.userId isEqualToString:noti_user.userId]) {
            [self toast:@"您不能重复选择同一个人员"];
            return;
        }
    }
    currentUser = noti_user;
    if (selectedCell) {
        [selectedCell.selectionButton setTitle:currentUser.username forState:UIControlStateNormal];
        [selectedPersonAry addObject:currentUser];
        selectedCell.user = currentUser;
    }
}

- (void)selectUserCancel:(NSNotification *)notification
{
    if (deleteUser == nil) {
        return;
    }
    if (selectedCell) {
        [selectedCell.selectionButton setTitle:deleteUser.username forState:UIControlStateNormal];
        [selectedPersonAry addObject:deleteUser];
        selectedCell.user = deleteUser;
    }
    deleteUser = nil;
}

- (void)addDepartmentComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self toast:@"部门添加成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateDepartmentComplete:(NSNotification *)notification
{
    [self stopLoading];
    if ([self doResponse:notification.userInfo]) {
        [self toast:@"部门修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 
#pragma mark 界面处理
- (void)initNewDepartmentViewController
{
    [self registNotification];
    [self addRightButtonItem];
    
    //tableview initialize
    rowNumber = 2;
    selectedPersonAry = [NSMutableArray array];
    addDepartmentPersonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [addDepartmentPersonTableView setEditing:YES animated:YES];
    rowNumberSuperDepartmentTableView = 2;
    selectedSuprerDepartmentAry = [NSMutableArray array];
    selectSuperDepartmentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [selectSuperDepartmentTableView setEditing:YES animated:YES];
    
    //initialize over
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    if (self.currentDepartmentADO) {
        departmentNameTxT.text = self.currentDepartmentADO.deptname;
        
        CDDepartmentDAO *tempDAO = [[CDDepartmentDAO alloc] init];
        CDDepartment *dept = [tempDAO findById:self.currentDepartmentADO.parentId];
        currentDepartment = dept;
        
        if (self.currentDepartmentADO.parentId) {
            [self initSuperDepartmentTableView];
        }
        
        if (self.currentDepartmentADO.owneremail) {
            [self initSelectPersonTableView];
        }
    }
    if (self.isUpdate) {
//        departmentNameTxT.userInteractionEnabled = NO;
    }
    else
    {
        currentDepartment = self.superDepartment;
        if (![VerifyHelper isEmpty:self.superDepartment.deptname]) {
            [self initSuperDepartmentTableViewWhenAddNew];
        }
    }
}

- (void)initSelectPersonTableView
{
    NSArray *leaderEmailAry = [self.currentDepartmentADO.owneremail componentsSeparatedByString:@","];
    for (int i = 0; i<[leaderEmailAry count]; i++) {
        CDUserDAO *userD = [[CDUserDAO alloc] init];
        CDUser *temp = [userD findByEmail:leaderEmailAry[i]];
        if (temp !=nil) {
            [selectedPersonAry addObject:temp];
        }
    }
    rowNumber = [selectedPersonAry count]+1;
    [addDepartmentPersonTableView reloadData];
    tableHeight = [NSLayoutConstraint constraintWithItem:addDepartmentPersonTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumber];
    [addDepartmentPersonTableView addConstraint:tableHeight];
}

- (void)initSuperDepartmentTableViewWhenAddNew
{
    [selectedSuprerDepartmentAry addObject:self.superDepartment];
    rowNumberSuperDepartmentTableView = [selectedSuprerDepartmentAry count]+1;
    [selectSuperDepartmentTableView reloadData];
    tableHeighe_department = [NSLayoutConstraint constraintWithItem:selectSuperDepartmentTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumberSuperDepartmentTableView];
    [selectSuperDepartmentTableView addConstraint:tableHeighe_department];
}

- (void)initSuperDepartmentTableView
{
    NSArray *superDepartmentAry = [self.currentDepartmentADO.parentId componentsSeparatedByString:@","];
    for (int i = 0; i<[superDepartmentAry count]; i++) {
        CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
        CDDepartment *temp = [departmentDAO findById:superDepartmentAry[i]];
        if (temp !=nil) {
            [selectedSuprerDepartmentAry addObject:temp];
        }
    }
    rowNumberSuperDepartmentTableView = [selectedSuprerDepartmentAry count]+1;
    [selectSuperDepartmentTableView reloadData];
    tableHeighe_department = [NSLayoutConstraint constraintWithItem:selectSuperDepartmentTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumberSuperDepartmentTableView];
    [selectSuperDepartmentTableView addConstraint:tableHeighe_department];
}

- (void)addRightButtonItem
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(addCompleteDepartmentButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)showAddDepartmentLeader:(NewDepartmentCell *)cell
{
    cell.vLine.hidden = YES;
    cell.titleLabel.text = @"添加部门主管";
    cell.selectionButton.userInteractionEnabled = NO;
}

- (void)showDeleteDepartmentLeader:(NewDepartmentCell *)cell
{
    cell.titleLabel.text = @"部门主管";
    cell.vLine.hidden = NO;
}


- (void)showAddSuperDepartment:(NewDepartmentCell *)cell
{
    cell.vLine.hidden = YES;
    cell.titleLabel.text = @"添加上级部门";
    cell.selectionButton.userInteractionEnabled = NO;
}

- (void)showDeleteSuperDepartment:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"上级(归属地)";
    }
    else
    {
        cell.titleLabel.text = @"上级(业务部)";
    }
    cell.vLine.hidden = NO;
}

#pragma mark -
#pragma mark 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == selectSuperDepartmentTableView) {
        return rowNumberSuperDepartmentTableView;
    }
    else
    {
        return rowNumber;
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
    if (tableView == selectSuperDepartmentTableView) {
        if (rowNumberSuperDepartmentTableView-1 == indexPath.row) {
            [self showAddSuperDepartment:cell];
        }
        else
        {
            [self showDeleteSuperDepartment:cell andIndexPath:indexPath];
            if (selectedSuprerDepartmentAry&&indexPath.row<[selectedSuprerDepartmentAry count]) {
                CDDepartment *tempDepartment = selectedSuprerDepartmentAry[indexPath.row];
                cell.department = tempDepartment;
                [cell.selectionButton setTitle:tempDepartment.deptname forState:UIControlStateNormal];
            }
            else
            {
                [cell.selectionButton setTitle:@"请选择" forState:UIControlStateNormal];
            }
            [cell.selectionButton addTarget:self action:@selector(cellSelectedSuperDepartmentWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        if (rowNumber-1 == indexPath.row) {
            [self showAddDepartmentLeader:cell];
        }
        else
        {
            [self showDeleteDepartmentLeader:cell];
            if (selectedPersonAry&&indexPath.row<[selectedPersonAry count]) {
                CDUser *tempUser = selectedPersonAry[indexPath.row];
                cell.user = tempUser;
                [cell.selectionButton setTitle:tempUser.username forState:UIControlStateNormal];
            }
            else
            {
                [cell.selectionButton setTitle:@"请选择" forState:UIControlStateNormal];
            }
            [cell.selectionButton addTarget:self action:@selector(cellSelectedWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
   
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == selectSuperDepartmentTableView) {
        if (indexPath.row == rowNumberSuperDepartmentTableView -1) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    else
    {
        if (indexPath.row == rowNumber -1) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewDepartmentCell *cell = (NewDepartmentCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView == selectSuperDepartmentTableView) {
        [self changeDepartmentTableViewWith:cell andIndexPath:indexPath];
    }
    else
    {
        [self changePersonTableViewWith:cell andIndexPath:indexPath];
    }
}

- (void)changeDepartmentTableViewWith:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if (cell.editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *tempAry = [selectedSuprerDepartmentAry copy];
        [selectedSuprerDepartmentAry removeAllObjects];
        for (int i =0; i<[tempAry count]; i++) {
            CDDepartment *obj = tempAry[i];
            if (![obj.deptId isEqualToString:cell.department.deptId]) {
                [selectedSuprerDepartmentAry addObject:obj];
            }
        }
        [selectSuperDepartmentTableView removeConstraint:tableHeighe_department];
        rowNumberSuperDepartmentTableView--;
        tableHeighe_department = [NSLayoutConstraint constraintWithItem:selectSuperDepartmentTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumberSuperDepartmentTableView];
        [selectSuperDepartmentTableView addConstraint:tableHeighe_department];
        [selectSuperDepartmentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [selectSuperDepartmentTableView reloadData];
    }
    else
    {
        rowNumberSuperDepartmentTableView++;
        [selectSuperDepartmentTableView removeConstraint:tableHeighe_department];
        tableHeighe_department = [NSLayoutConstraint constraintWithItem:selectSuperDepartmentTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumberSuperDepartmentTableView];
        [selectSuperDepartmentTableView addConstraint:tableHeighe_department];
        [selectSuperDepartmentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [selectSuperDepartmentTableView reloadData];
    }
}

- (void)changePersonTableViewWith:(NewDepartmentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if (cell.editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *tempAry = [selectedPersonAry copy];
        [selectedPersonAry removeAllObjects];
        for (int i = 0; i<[tempAry count]; i++) {
            CDUser *obj = tempAry[i];
            if (![obj.userId isEqualToString:cell.user.userId]) {
                [selectedPersonAry addObject:obj];
            }
        }
        [addDepartmentPersonTableView removeConstraint:tableHeight];
        rowNumber--;
        tableHeight = [NSLayoutConstraint constraintWithItem:addDepartmentPersonTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumber];
        [addDepartmentPersonTableView addConstraint:tableHeight];
        [addDepartmentPersonTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else
    {
        rowNumber++;
        [addDepartmentPersonTableView removeConstraint:tableHeight];
        tableHeight = [NSLayoutConstraint constraintWithItem:addDepartmentPersonTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.f*rowNumber];
        [addDepartmentPersonTableView addConstraint:tableHeight];
        [addDepartmentPersonTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

//scrollview
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [departmentNameTxT resignFirstResponder];
}

#pragma mark -
#pragma mark 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDepartmentOver:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectUserOver:) name:NOTIFICATION_SELECTED_USER_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDepartmentComplete:) name:ADD_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDepartmentComplete:) name:UPDATE_DEPARTMENT_NOTIFICAITON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDepartmentCancel:) name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectUserCancel:) name:NOTIFICATION_SELECTED_USER_IN_LIST_CANCEL object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_USER_IN_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_DEPARTMENT_NOTIFICAITON object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_DEPARTMENT_IN_LIST_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_USER_IN_LIST_CANCEL object:nil];
}
@end
