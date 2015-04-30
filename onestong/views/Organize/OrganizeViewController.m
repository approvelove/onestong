//
//  OrganizeViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "OrganizeViewController.h"
#import "DepartmentListCell.h"
#import "DepartmentsService.h"
#import "UsersService.h"
#import "UsersModel.h"
#import "DepartmentModel.h"
#import "NewDepartmentViewController.h"
#import "NewPersonViewController.h"
#import "ManagePersonViewController.h"
#import "EventsBoxViewController.h"
#import "TimeListViewController.h"
#import "VerifyHelper.h"
#import "CDDepartmentDAO.h"
#import "TabListViewController.h"
#import "TableListDetailViewController.h"
#import "TimeHelper.h"
#import "CDUserDAO.h"
#import "CDDepartment.h"

static const float Cell_Height_Two = 60.f;
@interface OrganizeViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *departmentAry;  //部门
    NSMutableArray *personAry;
    NSMutableArray *oldDepartmentAry;
    NSMutableArray *oldPersonAry;
    UISearchBar *mainSearchBar;
    DepartmentListCell *selectedCell;
}
@end

@implementation OrganizeViewController
@synthesize subDepartmentID,organizeMethod;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.organizeMethod = ORGANIZEORMANAGEMENTBACKGROUND_ORGANIZE;
    }
    return self;
}


#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.OSTTableView = mainTableView;
    [self initOriganizeViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
    if ((self.subDepartmentID == nil)&&(self.subDepartmentID.length == 0)) {
        [self sendRequestGetMyDepartment];
    }
    else
    {
        [self sendRequestGetMySubDepartment];
    }
    [self.OSTTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self freeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self freeNotification];
}

#pragma mark -
#pragma mark 界面事件处理

- (void)contextMenuCellDidSelectDeleteOption:(DAContextMenuCell *)cell
{
    DepartmentListCell *tempCell = nil;
    if ([cell isKindOfClass:[DepartmentListCell class]]) {
        tempCell = (DepartmentListCell *)cell;
        selectedCell = tempCell;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您确定要删除该信息？此操作不可撤销!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        [alert show];
    }
}

- (void)contextMenuCellDidSelectMoreOption:(DepartmentListCell *)cell
{
    //编辑
    if ([cell.cellClass isEqualToString:@"department"]) {
        NewDepartmentViewController *newDepartmentCtrl = [[NewDepartmentViewController alloc] initWithNibName:@"NewDepartmentViewController" bundle:nil];
        
        CDDepartment *departModel = [[[CDDepartmentDAO alloc] init] findById:cell.subDepartmentID];
        newDepartmentCtrl.currentDepartmentADO = departModel;
        newDepartmentCtrl.isUpdate = YES;
        newDepartmentCtrl.needFindDepartmentById = YES;
        [self.navigationController pushViewController:newDepartmentCtrl animated:YES];
    }
    else
    {
        NewPersonViewController *newPersonViewController = [[NewPersonViewController alloc] initWithNibName:@"NewPersonViewController" bundle:nil];
        newPersonViewController.isUpdate = YES;
        newPersonViewController.user = [[[CDUserDAO alloc] init] findById:cell.personID];
        [self.navigationController pushViewController:newPersonViewController animated:YES];
    }
}

- (void)addButtonClick:(id)sender
{
    [self addActionSheetOnView];
}


#pragma mark -
#pragma mark 界面逻辑处理
- (void)deleteRow
{
    NSIndexPath *index = selectedCell.indexpathNum;
    
    [selectedCell.superview sendSubviewToBack:selectedCell];
    
    if ([selectedCell.cellClass isEqualToString:@"department"]) {
        if (departmentAry&&departmentAry[index.row]) {
            [departmentAry removeObjectAtIndex:index.row];
            oldDepartmentAry = [departmentAry copy];
        }
    }
    else if ([selectedCell.cellClass isEqualToString:@"person"])
    {
        if (departmentAry) {
            NSLog(@"row = %ld",(long)index.row);
            if (personAry&&personAry[index.row-[departmentAry count]]) {
                [personAry removeObjectAtIndex:index.row-[departmentAry count]];
                oldPersonAry = [personAry copy];
            }
        }
        else
        {
            if (personAry&&personAry[index.row]) {
                [personAry removeObjectAtIndex:index.row];
                oldPersonAry = [personAry copy];
            }
        }
    }
    
    [self.OSTTableView deleteRowsAtIndexPaths:@[[self.OSTTableView indexPathForCell:selectedCell]] withRowAnimation:UITableViewRowAnimationRight];
    [self.OSTTableView reloadData];
}


- (void)deleteOwnDepartmentComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        [self deleteRow];
        [self toast:@"删除成功"];
    }
}

- (void)deleteUserComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        [self deleteRow];
        [self toast:@"删除成功"];
    }
}

- (void)forbidEditDepartmentWithCell:(DepartmentListCell *)cell
{
    for (UIPanGestureRecognizer *temp in [cell gestureRecognizers]) {
        if ([temp isMemberOfClass:[UIPanGestureRecognizer class]]) {
            [cell removeGestureRecognizer:temp];
        }
    }
}

- (void)addActionSheetOnView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加部门", @"添加成员",nil];
    [actionSheet showInView:self.view];
}

- (void)findOwnDepartmentsComplete:(NSNotification *)notification
{
    if (notification.userInfo[@"resultData"]) {
        departmentAry = notification.userInfo[@"resultData"];
        oldDepartmentAry = [NSMutableArray arrayWithArray:departmentAry];
        [mainTableView reloadData];
    }
}

- (void)findLowerDepartmentsComplete:(NSNotification *)notification
{
    if (notification.userInfo[@"resultData"]) {
        departmentAry = notification.userInfo[@"resultData"];
        oldDepartmentAry = [NSMutableArray arrayWithArray:departmentAry];
        [mainTableView reloadData];
    }
    [self sendRequestGetSubMySubordinate];
}

- (void)findDepartmentUsersComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        if (personAry) {
            [personAry removeAllObjects];
        }
        if(notification.userInfo[@"resultData"]) {
            [personAry addObjectsFromArray:notification.userInfo[@"resultData"]];
        }
        oldPersonAry = [NSMutableArray arrayWithArray:personAry];
        [mainTableView reloadData];
    }
}


- (void)resignResponder
{
    if (mainSearchBar) {
        [mainSearchBar resignFirstResponder];
    }
}

-(void)sendRequestGetMyDepartment
{
    DepartmentsService *departmentService = [[DepartmentsService alloc] init];
    [departmentService findOwnDepartments];
}

- (void)sendRequestGetMySubDepartment
{
    DepartmentsService *departmentService = [[DepartmentsService alloc] init];
    [departmentService findLowerDepartments:self.subDepartmentID];
}

- (void)sendRequestGetMySubordinate
{
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *userModel = [userService getCurrentUser];
    [userService findDepartmentUsers:userModel.department.modelId];
}

- (void)sendRequestGetSubMySubordinate
{
    UsersService *userService = [[UsersService alloc] init];
    [userService findDepartmentUsers:self.subDepartmentID];
}


#pragma mark -
#pragma mark 界面操作
- (void)contextMenuDidHideInCell:(DAContextMenuCell *)cell
{
    [super contextMenuDidHideInCell:cell];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
}

- (void)initOriganizeViewController
{
    //查询自己所在部门
    if (![VerifyHelper isEmpty:self.subDepartmentID]) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClick:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    departmentAry = [NSMutableArray array];
    personAry = [NSMutableArray array];
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

- (void)sendRequestDeleteUserById:(NSString *)userId
{
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *model = [[UsersModel alloc] init];
    model.userId = userId;
    [userService deleteUser:model];
}

- (void)sendRequestDeleteDepartmentWithDepartmentId:(NSString *)departmentId
{
    DepartmentsService *departmentService = [[DepartmentsService alloc] init];
    DepartmentModel *departmentModel = [[DepartmentModel alloc] init];
    departmentModel.departmentId = departmentId;
    [departmentService deleteDepartment:departmentModel];
}

#pragma mark delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (!selectedCell) {
            return;
        }
        if ([selectedCell.cellClass isEqualToString:@"person"]) {
            [self sendRequestDeleteUserById:selectedCell.personID];
        }
        else
        {
            [self sendRequestDeleteDepartmentWithDepartmentId:selectedCell.subDepartmentID];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NewDepartmentViewController *newDepartmentCtrl = [[NewDepartmentViewController alloc] initWithNibName:@"NewDepartmentViewController" bundle:nil];
        newDepartmentCtrl.navigationItem.title = @"新建部门";
        newDepartmentCtrl.isUpdate = NO;
        CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
        newDepartmentCtrl.superDepartment = [VerifyHelper isEmpty:self.subDepartmentID]?[deptDAO findById:@"1"]:[deptDAO findById:self.subDepartmentID];
        [self.navigationController pushViewController:newDepartmentCtrl animated:YES];
    }
    else if (1 == buttonIndex)
    {
        NewPersonViewController *newPersonCtrl = [[NewPersonViewController alloc] initWithNibName:@"NewPersonViewController" bundle:nil];
        newPersonCtrl.isUpdate = NO;
        CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
        newPersonCtrl.superDepartment = [VerifyHelper isEmpty:self.subDepartmentID]? [deptDAO findById:@"1"]:[deptDAO findById:self.subDepartmentID];
        [self.navigationController pushViewController:newPersonCtrl animated:YES];
    }
}

//tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [headerView addSubview:[self addSearchBar]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height_Two;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //总有一个搜索栏
    NSInteger row_number = 0;
    if (departmentAry&&([departmentAry count]>0)) {
        row_number += [departmentAry count];
    }
    if (personAry&&([personAry count]>0)) {
        row_number += [personAry count];
    }
    return row_number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    DepartmentListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [DepartmentListCell loadFromNib];
        if (self.organizeMethod == ORGANIZEORMANAGEMENTBACKGROUND_MANAGEMENTBACKGROUND) {
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (CURRENT_VERSION<7) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    cell.indexpathNum = indexPath;
//    if ([VerifyHelper isEmpty:self.subDepartmentID]) {
//        [self forbidEditDepartmentWithCell:cell];
//    }
    [self forbidEditDepartmentWithCell:cell];
    if (departmentAry&&([departmentAry count]>0)) {
        if(indexPath.row<[departmentAry count])
        {
            //索引值减1
            DepartmentModel *departModel = departmentAry[indexPath.row];
            cell.leftImageView.image = [UIImage imageNamed:@"department"];
            cell.secondLabel.text = departModel.departmentName;
            cell.secondLabel.font = [UIFont systemFontOfSize:14.f];
            cell.cellClass = @"department"; //部门标识
            cell.subDepartmentID = departModel.departmentId;
            if (departModel.parentName&&departModel.parentName.length>0) {
                cell.subTitleLabel.text = [NSString stringWithFormat:@"%@",departModel.parentName];
            }
            else
            {
                cell.secondLabel.frame = CGRectMake(cell.secondLabel.frame.origin.x, 22, cell.secondLabel.frame.size.width, cell.secondLabel.frame.size.height);
            }
        }
    }
    
    if (personAry&&([personAry count]>0)) {
        if ((indexPath.row>=[departmentAry count])) {
            //indexPath.row-[departmentAry count];
            NSLog(@"personAry=%@",personAry);
            UsersModel *usersModel = personAry[indexPath.row-[departmentAry count]];
            cell.firstLabel.text = usersModel.username;
            cell.firstLabel.font = [UIFont systemFontOfSize:14.f];
            NSString *jsonStr = usersModel.companyPosition;
            if ([usersModel.validSign isEqualToString:@"1"]) {
                cell.secondLabel.text = @"";
                cell.firstLabel.textColor = [UIColor redColor];
            }
            else {
                NSString *positionStr = jsonStr;
                cell.position = positionStr;
            }
            cell.user = usersModel;
            cell.personEmail = usersModel.email;
            cell.cellName = usersModel.username;
            cell.personID = usersModel.userId;
            cell.cellClass = @"person";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignResponder];
    DepartmentListCell *cell = (DepartmentListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.cellClass isEqualToString:@"department"]) {
        //处理部门
        OrganizeViewController *subOrganizeCtrl = [[OrganizeViewController alloc] initWithNibName:@"OrganizeViewController" bundle:nil];
        subOrganizeCtrl.navigationItem.title = cell.secondLabel.text;
        subOrganizeCtrl.subDepartmentID = cell.subDepartmentID;
        subOrganizeCtrl.organizeMethod = self.organizeMethod;
        [self.navigationController pushViewController:subOrganizeCtrl animated:YES];
    }
    else if ([cell.cellClass isEqualToString:@"person"]) {
        //点击人之后进入事件箱页面
            CDUserDAO *userDAO = [[CDUserDAO alloc] init];
            CDUser *tempUser = [userDAO findById:cell.personID];
            ManagePersonViewController *manageCtrl = [[ManagePersonViewController alloc] initWithNibName:@"ManagePersonViewController" bundle:nil];
            manageCtrl.user = tempUser;
            [self.navigationController pushViewController:manageCtrl animated:YES];
            return;
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    DepartmentListCell *cell = (DepartmentListCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    if ([cell.cellClass isEqualToString:@"person"]) {
        if ([cell.user.validSign isEqualToString:@"1"]) {
            [self showAlertwithTitle:@"该用户尚未激活"];
            return;
        }
        TableListDetailViewController *tldCtrl = [[TableListDetailViewController alloc] initWithNibName:@"TableListDetailViewController" bundle:nil];
        tldCtrl.selecteduserId = cell.personID;
        NSString *beginDateStr = [TimeHelper getYearMonthDayWithDate:[NSDate date]];
        NSString *endDateStr = beginDateStr;
        tldCtrl.superBeginDateStr = beginDateStr;
        tldCtrl.superEndDateStr = endDateStr;
        tldCtrl.rightItemTitle = @"外访";
        tldCtrl.navTitleTimeStr = @"今日";
        [self.navigationController pushViewController:tldCtrl animated:YES];
    }
    
    else if ([cell.cellClass isEqualToString:@"department"]) {
        CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
        CDDepartment *tempDepartment = [departmentDAO findById:cell.subDepartmentID];
        TabListViewController *tlvCtrl = [[TabListViewController alloc] initWithNibName:@"TabListViewController" bundle:nil];
        tlvCtrl.selectedDepartment = tempDepartment;
        [self.navigationController pushViewController:tlvCtrl animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchStringWithString:searchText];
    [mainTableView reloadData];
    if (mainSearchBar) {
        [mainSearchBar becomeFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self resignResponder];
}


//搜索
- (void)searchStringWithString:(NSString *)searchText
{
    if (departmentAry) {
        [departmentAry removeAllObjects];
    }
    if (oldDepartmentAry&&([oldDepartmentAry count]>0)) {
        [departmentAry addObjectsFromArray:oldDepartmentAry];
    }
    if (personAry) {
        [personAry removeAllObjects];
    }
    if (oldPersonAry&&([oldPersonAry count]>0)) {
        [personAry addObjectsFromArray:oldPersonAry];
    }
    if ([searchText isEqualToString:@""]||searchText == nil) {
        return;
    }
    if (departmentAry&&([departmentAry count]>0)) {
        //部门主要搜索部门名字
        NSMutableArray *tempDepartment = [NSMutableArray array];
        for (int i=0; i<[departmentAry count]; i++) {
            
            DepartmentModel *departModel = departmentAry[i];
            NSString *departmentName = departModel.departmentName;
            NSRange range = [departmentName rangeOfString:searchText];
            if (range.length==0) {
                [tempDepartment addObject:departmentAry[i]];
            }
        }
        [departmentAry removeObjectsInArray:tempDepartment];
        
    }
    if (personAry&&([personAry count]>0)) {
        //下属主要搜索名字和职位
        NSMutableArray *tempperson = [NSMutableArray array];
        for (int i=0; i<[personAry count]; i++) {
            UsersModel *userModel = personAry[i];
            NSString *position= userModel.companyPosition;  //职位
            NSString *username = userModel.username; //名字
            NSRange porange = [position rangeOfString:searchText];
            NSRange usrange = [username rangeOfString:searchText];
            if ((porange.length==0)&&(usrange.length==0)) {
                [tempperson addObject:personAry[i]];
            }
        }
        [personAry removeObjectsInArray:tempperson];
    }
}

#pragma mark -
#pragma mark 通知管理

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findOwnDepartmentsComplete:) name:FIND_OWN_DEPARTMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findLowerDepartmentsComplete:) name:FIND_LOWER_DEPARTMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDepartmentUsersComplete:) name:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOwnDepartmentComplete:) name:DELETE_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserComplete:) name:DELETE_USER_COMPLETE_NOTIFICATION object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_LOWER_DEPARTMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_OWN_DEPARTMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_USER_COMPLETE_NOTIFICATION object:nil];
}
@end
