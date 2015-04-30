//
//  OrganizeViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "MapPathChartDepartmenListViewController.h"
#import "MapPathChartDepartmentCell.h"
#import "CDDepartmentDAO.h"
#import "CDDepartment.h"
#import "DepartmentsService.h"
#import "CDUserDAO.h"
#import "CDUser.h"
#import "EventsBoxViewController.h"
#import "EventsService.h"

static const float Cell_Height_Two = 60.f;
@interface MapPathChartDepartmenListViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *departmentAry;  //部门
    NSMutableArray *personAry;  //人
    
    UISearchBar *mainSearchBar;
    MapPathChartDepartmentCell *selectedCell;
    
    NSMutableArray *constDepartmentAry;
    NSMutableArray *constPersonAry; //人
}
@end

@implementation MapPathChartDepartmenListViewController
@synthesize superDepartmentID;

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
    [self initOriganizeViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
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
    if (constDepartmentAry) {
        [constDepartmentAry removeAllObjects];
        constDepartmentAry = nil;
    }
    constDepartmentAry = [@[] mutableCopy];
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc]init];
    departmentAry = [NSMutableArray array];
    UsersModel *owner = [[[EventsService alloc] init] getCurrentUser];
    CDUser *CDOwner = [[[CDUserDAO alloc] init] findById:owner.userId];
    NSArray *deptIdAry = [CDOwner.ca componentsSeparatedByString:@","];
    for (int i= 0; i<deptIdAry.count; i++) {
        CDDepartment *tempD = [departmentDAO findById:deptIdAry[i]];
        if (tempD) {
            [constDepartmentAry addObject:tempD];
        }
    }
    departmentAry = [NSMutableArray arrayWithArray:constDepartmentAry];
    [mainTableView reloadData];
}

- (void)sendRequestGetMySubDepartment
{
    CDDepartmentDAO *departmentDAO = [[CDDepartmentDAO alloc] init];
    constDepartmentAry = [NSMutableArray array];
    if ([departmentDAO findByParentId:self.superDepartmentID]) {
        [constDepartmentAry addObjectsFromArray:[departmentDAO findByParentId:self.superDepartmentID]];
    }
    
    departmentAry = [constDepartmentAry mutableCopy];
    [mainTableView reloadData];
    [self sendRequestGetSubMySubordinate];
}

- (void)sendRequestGetSubMySubordinate
{
    CDUserDAO *userDAO = [[CDUserDAO alloc] init];
    constPersonAry = [[userDAO findByDepartmentId:self.superDepartmentID] mutableCopy];
    personAry = [constPersonAry mutableCopy];
    [mainTableView reloadData];
}

//- (void)findLowerDepartmentsComplete:(NSNotification *)notification
//{
//    if (notification.userInfo[@"resultData"]) {
//        departmentAry = notification.userInfo[@"resultData"];
//        [mainTableView reloadData];
//    }
//    [self sendRequestGetSubMySubordinate];
//}

#pragma mark -
#pragma mark 界面操作

- (void)initOriganizeViewController
{
    //查询自己所在部门
    departmentAry = [NSMutableArray array];
    personAry = [NSMutableArray array];
    if ((self.superDepartmentID == nil)&&(self.superDepartmentID.length == 0)) {
        [self sendRequestGetMyDepartment];
    }
    else
    {
        [self sendRequestGetMySubDepartment];
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


#pragma mark -
#pragma mark  代理处理

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
    MapPathChartDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [MapPathChartDepartmentCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
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
    MapPathChartDepartmentCell *cell = (MapPathChartDepartmentCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.cellClass isEqualToString:@"department"]) {
        //处理部门
        MapPathChartDepartmenListViewController *subOrganizeCtrl = [[MapPathChartDepartmenListViewController alloc] initWithNibName:@"MapPathChartDepartmenListViewController" bundle:nil];
        subOrganizeCtrl.navigationItem.title = cell.secondLabel.text;
        subOrganizeCtrl.superDepartmentID = cell.subDepartmentID;
        [self.navigationController pushViewController:subOrganizeCtrl animated:YES];
    }
    else if ([cell.cellClass isEqualToString:@"person"]) {
        EventsBoxViewController *eventBox = [[EventsBoxViewController alloc] initWithNibName:@"EventsBoxViewController" bundle:nil];
        eventBox.currentBox = Box_Other_Mapchart;
        UsersModel *user = [[UsersModel alloc] init];
        user.email = cell.personEmail;
        user.userId = cell.personID;
        eventBox.currentUser = user;
        [self.navigationController pushViewController:eventBox animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchStringWithString:searchText];
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
    if (!searchText||[searchText isEqualToString:@""]) {
        departmentAry = [constDepartmentAry mutableCopy];
        personAry = [constPersonAry mutableCopy];
    }
    else
    {
        departmentAry = [@[] mutableCopy];
        for (int i = 0; i<[constDepartmentAry count];i++) {
            NSLog(@"i = %d",i);
            CDDepartment *obj = constDepartmentAry[i];
            NSRange tempRange = [obj.deptname rangeOfString:searchText];
            if (tempRange.length>0) {
                [departmentAry addObject:obj];
            }
        }
        
        personAry = [@[] mutableCopy];
        for (int i = 0; i<[constPersonAry count]; i++) {
            CDUser *obj = constPersonAry[i];
            NSRange tempRange = [obj.username rangeOfString:searchText];
            if (tempRange.length>0) {
                [personAry addObject:obj];
            }
        }
    }
    [mainTableView reloadData];
}

#pragma mark -
#pragma mark 通知管理

- (void)registNotification
{
}
- (void)freeNotification
{
}
@end
