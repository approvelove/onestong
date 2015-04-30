//
//  OrganizeViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DepartmentAndUserViewController.h"
#import "DepartmentAndUserListCell.h"
#import "TimeListViewController.h"
#import "NewDepartmentViewController.h"
#import "NewPersonViewController.h"
#import "ManagePersonViewController.h"
#import "CDDepartmentDAO.h"
#import "CDUserDAO.h"
#import "CDUser.h"
#import "CDDepartment.h"
#import "DepartmentsService.h"
#import "UsersService.h"
#import "NewPersonViewController.h"
#import "VerifyHelper.h"

static const float Cell_Height_Two = 60.f;
static NSString * const COMPANY_NAME = @"管理部门";

@interface DepartmentAndUserViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *departmentAry;  //部门
    NSMutableArray *personAry;
    NSMutableArray *oldDepartmentAry;
    NSMutableArray *oldPersonAry;
    UISearchBar *mainSearchBar;
    DepartmentAndUserListCell *selectedCell;
}
@end

@implementation DepartmentAndUserViewController
@synthesize superDepartmentID,constFatherDepartmentId;

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
    self.OSTTableView = mainTableView;
    // Do any additional setup after loading the view from its nib.
    [self initOriganizeViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
    if (((self.superDepartmentID == nil)&&(self.superDepartmentID.length == 0))) {
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
    DepartmentAndUserListCell *tempCell = nil;
    if ([cell isKindOfClass:[DepartmentAndUserListCell class]]) {
        tempCell = (DepartmentAndUserListCell *)cell;
        selectedCell = tempCell;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您确定要删除该信息？此操作不可撤销!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        [alert show];
    }
}

- (void)contextMenuCellDidSelectMoreOption:(DepartmentAndUserListCell *)cell
{
    
    //编辑
    if ([cell.cellClass isEqualToString:@"department"]) {
        NewDepartmentViewController *newDepartmentCtrl = [[NewDepartmentViewController alloc] initWithNibName:@"NewDepartmentViewController" bundle:nil];
        CDDepartment *departModel = [[[CDDepartmentDAO alloc] init] findById:cell.departmentModel.deptId];
        newDepartmentCtrl.currentDepartmentADO = departModel;
        newDepartmentCtrl.isUpdate = YES;
        newDepartmentCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
        [self.navigationController pushViewController:newDepartmentCtrl animated:YES];
    }
    else
    {
        NewPersonViewController *newPersonViewController = [[NewPersonViewController alloc] initWithNibName:@"NewPersonViewController" bundle:nil];
        newPersonViewController.isUpdate = YES;
        newPersonViewController.user = cell.user;
        newPersonViewController.constFatherDepartmentId = self.constFatherDepartmentId;
        [self.navigationController pushViewController:newPersonViewController animated:YES];
    }
}


- (void)addButtonClick:(id)sender
{
    [self addActionSheetOnView];
}
#pragma mark -
#pragma mark 界面逻辑处理

- (void)resignResponder
{
    if (mainSearchBar) {
        [mainSearchBar resignFirstResponder];
    }
}

-(void)sendRequestGetMyDepartment
{
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc]init];
    departmentAry = [NSMutableArray array];
    UsersModel *owner = [[[UsersService alloc] init] getCurrentUser];
    CDUser *CDOwner = [[[CDUserDAO alloc] init] findById:owner.userId];
    NSArray *deptIdAry = [CDOwner.da componentsSeparatedByString:@","];
    for (int i= 0; i<deptIdAry.count; i++) {
        CDDepartment *tempD = [departmentDAO findById:deptIdAry[i]];
        if (tempD) {
            [departmentAry addObject:tempD];
        }
    }
    oldDepartmentAry = [NSMutableArray arrayWithArray:departmentAry];
    [self.OSTTableView reloadData];
//    [self sendRequestGetMySubordinate];
}

- (void)sendRequestGetMySubDepartment
{
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
    departmentAry = [NSMutableArray array];
    
    NSArray *tempDeptAry = [departmentDAO findByParentId:self.superDepartmentID];
    if (tempDeptAry) {
        [departmentAry addObjectsFromArray:tempDeptAry];
    }
    oldDepartmentAry = [NSMutableArray arrayWithArray:departmentAry];
    [self.OSTTableView reloadData];
    [self sendRequestGetSubMySubordinate];
}

- (void)sendRequestGetMySubordinate
{
    if (personAry) {
        [personAry removeAllObjects];
    }
    CDUserDAO *userDAO = [[CDUserDAO alloc] init];
    personAry = [[userDAO findByDepartmentId:@"1"] mutableCopy];
    if (personAry) {
        oldPersonAry = [NSMutableArray arrayWithArray:personAry];
        [self.OSTTableView reloadData];
    }
}

- (void)sendRequestGetSubMySubordinate
{
    CDUserDAO *userDAO = [[CDUserDAO alloc] init];
    if (personAry) {
        [personAry removeAllObjects];
    }
    if ([userDAO findByDepartmentId:self.superDepartmentID]) {
        [personAry addObjectsFromArray:[userDAO findByDepartmentId:self.superDepartmentID]];
        oldPersonAry = [NSMutableArray arrayWithArray:personAry];
        [self.OSTTableView reloadData];
    }
}

- (void)sendRequestDeleteDepartmentWithDepartmentId:(NSString *)departmentId
{
    DepartmentsService *departmentService = [[DepartmentsService alloc] init];
    DepartmentModel *departmentModel = [[DepartmentModel alloc] init];
    departmentModel.departmentId = departmentId;
    [departmentService deleteDepartment:departmentModel];
}

- (void)findLowerDepartmentsComplete:(NSNotification *)notification
{
    if (notification.userInfo[@"resultData"]) {
        departmentAry = notification.userInfo[@"resultData"];
        oldDepartmentAry = [NSMutableArray arrayWithArray:departmentAry];
        [self.OSTTableView reloadData];
    }
    [self sendRequestGetSubMySubordinate];
}


- (void)deleteOwnDepartmentComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        [self deleteRow];
        [self toast:@"删除成功"];
    }
}

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
            NSLog(@"row = %d",index.row);
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

- (void)sendRequestDeleteUserById:(NSString *)userId
{
    UsersService *userService = [[UsersService alloc] init];
    UsersModel *model = [[UsersModel alloc] init];
    model.userId = userId;
    [userService deleteUser:model];
}

- (void)deleteUserComplete:(NSNotification *)notification
{
    if ([self doResponse:notification.userInfo]) {
        [self deleteRow];
        [self toast:@"删除成功"];
    }
}
#pragma mark -
#pragma mark 界面操作

- (void)initOriganizeViewController
{
    if (![VerifyHelper isEmpty:self.superDepartmentID]) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClick:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    //查询自己所在部门
    departmentAry = [NSMutableArray array];
    personAry = [NSMutableArray array];
    if ([VerifyHelper isEmpty:superDepartmentID]) {
        self.navigationItem.title = COMPANY_NAME;
    }
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


- (void)addActionSheetOnView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加部门", @"添加成员",nil];
    [actionSheet showInView:self.view];
}
#pragma mark -
#pragma mark  代理处理

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
//actionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NewDepartmentViewController *newDepartmentCtrl = [[NewDepartmentViewController alloc] initWithNibName:@"NewDepartmentViewController" bundle:nil];
        newDepartmentCtrl.navigationItem.title = @"新建部门";
        newDepartmentCtrl.isUpdate = NO;
        CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
        newDepartmentCtrl.superDepartment = [VerifyHelper isEmpty:self.superDepartmentID]?[deptDAO findById:@"1"]:[deptDAO findById:self.superDepartmentID];
        newDepartmentCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
        [self.navigationController pushViewController:newDepartmentCtrl animated:YES];
    }
    else if (1 == buttonIndex)
    {
        NewPersonViewController *newPersonCtrl = [[NewPersonViewController alloc] initWithNibName:@"NewPersonViewController" bundle:nil];
        newPersonCtrl.isUpdate = NO;
        CDDepartmentDAO *deptDAO = [[CDDepartmentDAO alloc] init];
        newPersonCtrl.superDepartment = [VerifyHelper isEmpty:self.superDepartmentID]? [deptDAO findById:@"1"]:[deptDAO findById:self.superDepartmentID];
        newPersonCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
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
    DepartmentAndUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [DepartmentAndUserListCell loadFromNib];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.indexpathNum = indexPath;
    if (departmentAry&&([departmentAry count]>0)) {
        if(indexPath.row<[departmentAry count])
        {
            //索引值减1
            CDDepartment *departModel = departmentAry[indexPath.row];
            cell.leftImageView.image = [UIImage imageNamed:@"department"];
            cell.secondLabel.text = departModel.deptname;
            cell.secondLabel.font = [UIFont systemFontOfSize:14.f];
            cell.cellClass = @"department"; //部门标识
            cell.subDepartmentID = departModel.deptId;
            cell.departmentModel = departModel;
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
            CDUser *usersModel = personAry[indexPath.row-[departmentAry count]];
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
    DepartmentAndUserListCell *cell = (DepartmentAndUserListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.cellClass isEqualToString:@"department"]) {
        //处理部门
        DepartmentAndUserViewController *subOrganizeCtrl = [[DepartmentAndUserViewController alloc] initWithNibName:@"DepartmentAndUserViewController" bundle:nil];
        subOrganizeCtrl.navigationItem.title = cell.secondLabel.text;
        subOrganizeCtrl.superDepartmentID = cell.subDepartmentID;
        if ([VerifyHelper isEmpty:self.superDepartmentID]) {
            subOrganizeCtrl.constFatherDepartmentId = cell.subDepartmentID;
        }
        else
        {
            subOrganizeCtrl.constFatherDepartmentId = self.constFatherDepartmentId;
        }
        [self.navigationController pushViewController:subOrganizeCtrl animated:YES];
    }
    else if ([cell.cellClass isEqualToString:@"person"]) {
        //点击人之后进入事件箱页面
        ManagePersonViewController *manageCtrl = [[ManagePersonViewController alloc] initWithNibName:@"ManagePersonViewController" bundle:nil];
        manageCtrl.user = cell.user;
        [self.navigationController pushViewController:manageCtrl animated:YES];
        return;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchStringWithString:searchText];
    [self.OSTTableView reloadData];
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
            
            CDDepartment *departModel = departmentAry[i];
            NSString *departmentName = departModel.deptname;
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
            CDUser *userModel = personAry[i];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOwnDepartmentComplete:) name:DELETE_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserComplete:) name:DELETE_USER_COMPLETE_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDepartmentUsersComplete:) name:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION object:nil];
}
- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_DEPARTMENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_USER_COMPLETE_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_DEPARTMENT_USERS_COMPLETE_NOTIFICATION object:nil];
}
@end
