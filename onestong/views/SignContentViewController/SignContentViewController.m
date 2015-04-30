//
//  SignContentViewController.m
//  onestong
//
//  Created by 李健 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SignContentViewController.h"
#import "GraphicHelper.h"
#import "OSTTextView.h"
#import "ImageWall.h"
#import "EventModel.h"
#import "EventsService.h"
#import "OSTImageView.h"
#import "ImageShowViewController.h"
#import "LocationHelper.h"
#import "MKMapView+LongPressGesture.h"
#import "UIImageView+WebCache.h"
#import "SignContentList.h"
#import "VerifyHelper.h"


#define MAX_WORD_LENGTH 500
static NSInteger MAX_MAP_ZOOMLEVEL = 20;
@interface SignContentViewController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MKMapViewDelegate,SignContentListDelegate,NSCoding>
{
    __weak IBOutlet OSTTextView *commentTextView;
    __weak IBOutlet ImageWall *ostImageWall;
    
    __weak IBOutlet OSTImageView *imageViewOne;
    __weak IBOutlet OSTImageView *imageViewTwo;
    __weak IBOutlet UITextField *eventNameField;
    
    __weak IBOutlet NSLayoutConstraint *layoutTop;
    __weak IBOutlet NSLayoutConstraint *mapViewLayOutTop;
    __weak IBOutlet NSLayoutConstraint *imageWallLayOutTop;
    
    __weak OSTImageView *currentImageView;
    
    __weak IBOutlet MKMapView *ostMapView;
    LocationHelper *locationGetter;
    NSMutableDictionary *signLocationDictionary;
    BOOL hasfullyRendered;
    BOOL locationUsing;
    BOOL hasSetMaxMapZoomLevel;
    UIImagePickerController *pickerView;
    BOOL hasSendRequest;
    SignContentList *signList;
    BOOL needArchive;
}
@end

@implementation SignContentViewController
@synthesize mainFoundation,signedIncoordinate,currentEventModel,vaildAttendanceSignIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hasfullyRendered = NO;
        locationUsing = NO;
        hasSetMaxMapZoomLevel = NO;
        hasSendRequest = NO;
    }
    return self;
}

#pragma mark -
#pragma mark 重写系统界面操作
- (void)viewDidLoad
{
    [super viewDidLoad];
    needArchive = YES;
    [self initSignContentCtrl];
    [self unarchiverPageData];
}


- (void)showRoot
{
    if (pickerView) {
        [pickerView dismissViewControllerAnimated:NO completion:nil];
    }
    [super showRoot];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //归档数据
    if (needArchive) {
        [self archiverPageData];
    }
    [self freeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self freeNotification];
    [self freeNotificationDeleteOSTImage];
}

#pragma mark -
#pragma mark 界面事件处理
- (void)navTitleClick
{
    if (signList) {
        [self removeTableList];
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    signList = [SignContentList loadFromNib];
    signList.dataSource = [defaults objectForKey:@"eventList"];
    UIButton *navBtn = (UIButton *)self.navigationItem.titleView;
    signList.selectString = navBtn.titleLabel.text;
    signList.delegate = self;
    signList.frame = CGRectMake(60, 64, signList.frame.size.width, signList.frame.size.height);
    [self showView:signList];
    [self.view addSubview:signList];
}

- (void)sendButtonClick:(id)sender
{
    [self registLocationNotification];
    hasSendRequest = NO;
    locationUsing = NO;
    [self performSelector:@selector(dealWithTimeOut) withObject:self afterDelay:20.f];
    switch (self.mainFoundation) {
        case MAINFOUNDATION_SING_IN:
            if ([VerifyHelper isEmpty:eventNameField.text] && [VerifyHelper isEmpty:commentTextView.text] && !imageViewOne.imageSetted) {
                [self showAlertwithTitle:@"您未填写任何内容，不能建立事件"];
                [self freeLocationNotification];
                return;
            }
            [self signInEvent];
            break;
        case MAINFOUNDATION_SING_OUT:
            if ([VerifyHelper isEmpty:eventNameField.text]) {
                [self showAlertwithTitle:@"您未填写客户或店面信息，不能签退"];
                [self freeLocationNotification];
                return;
            }
            [self signOutEvent];
            break;
        case MAINFOUNDATION_EDIT:
            [self remarkPictureEvent];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_IN:
            [self signInEvent];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_OUT:
            [self signOutEvent];
            break;
    }
}

- (void)selectOSTImage:(NSNotification *)notification
{
    currentImageView = notification.userInfo[@"obj"];
    [self actionsheetShow];
}

- (void)showOSTImage:(NSNotification *)notification
{
    currentImageView = notification.userInfo[@"obj"];
    ImageShowViewController *imageShowController = [[ImageShowViewController alloc] initWithNibName:@"ImageShowViewController" bundle:nil];
    imageShowController.screenimage = currentImageView.image;
    [self.navigationController pushViewController:imageShowController animated:YES];
}

- (void)startsystemImageLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerView = nil;
        pickerView = [[UIImagePickerController alloc] init];
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerView.delegate = self;
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:pickerView animated:YES completion:^{
            }];
        }
    }
}

- (void)startCameraController
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerView = [[UIImagePickerController alloc] init];
        pickerView.delegate = self;
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        pickerView.allowsEditing = NO;
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:pickerView animated:YES completion:^{
                [pickerView setShowsCameraControls:YES];
            }];
        }
    }
}


#pragma mark - 数据处理
- (void)archiverPageData
{
    if (self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_IN || self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_OUT) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archvier = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    NSString *Path = [self archiverFilePath];
    [archvier encodeObject:eventNameField.text?eventNameField.text:@"" forKey:@"eventName"];
    [archvier encodeObject:commentTextView.text?commentTextView.text:@"" forKey:@"commentText"];
    [archvier finishEncoding];
    [data writeToFile:Path atomically:YES];
}

- (NSString *)archiverFilePath
{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = @"default";
    switch (self.mainFoundation) {
        case MAINFOUNDATION_SING_IN:
        {
           fileName = @"signIn";
        }
            break;
        case MAINFOUNDATION_SING_OUT:
        {
           fileName = @"signOut";
        }
            break;
        case MAINFOUNDATION_EDIT:
        {
            fileName = @"edit";
        }
            break;
        default:
            break;
    }
    return [[array objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

- (void)unarchiverPageData
{
    if (self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_IN || self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_OUT) {
        return;
    }
    NSString *Path = [self archiverFilePath];
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:Path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *eventNameStr = [unarchiver decodeObjectForKey:@"eventName"];
    if ((![VerifyHelper isEmpty:eventNameStr]&&[VerifyHelper isEmpty:eventNameField.text])) {
         eventNameField.text = eventNameStr;
    }
    
    NSString *commentTextStr = [unarchiver decodeObjectForKey:@"commentText"];
    if ((![VerifyHelper isEmpty:commentTextStr])&&[VerifyHelper isEmpty:commentTextView.text]) {
        commentTextView.text = commentTextStr;
    }
    if (![VerifyHelper isEmpty:commentTextView.text]) {
        [self clearOrInstallPlaceHolderWithTextView:commentTextView];
    }
    [unarchiver finishDecoding];
    [self verifyCanClickSendButton];
}

#pragma mark -
#pragma mark 界面逻辑处理

- (void)showView:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [view.layer addAnimation:animation forKey:nil];
}

- (void)removeTableList
{
    [UIView animateWithDuration:0.35f animations:^(void){
        //animationView.hidden = NO;
        signList.frame = CGRectMake(60, -265, signList.frame.size.width, signList.frame.size.height);
    } completion:^(BOOL result){
        if (signList) {
            [signList removeFromSuperview];
            signList = nil;
        }
    }];
}

- (void)dealWithTimeOut
{
    if (!hasfullyRendered) {
        [self freeLocationNotification];
        [self stopLoading];
        [self showAlertwithTitle:@"请求超时，请重试"];
    }
}

- (void)locationError
{
    [self stopLoading];
    [self freeLocationNotification];
    [self showAlertwithTitle:@"地图正在渲染中。请稍后..."];
    hasfullyRendered = YES;
}

- (void)remarkPictureEvent
{
    [self startLoading:@"正在添加描述"];
    [self sendRequestRemarkPicture];
}

-(void)signInEvent
{
    
    [self startLoading:@"正在签到..."];
    
    [locationGetter startLocation];
}

-(void)signOutEvent
{
    [self startLoading:@"正在签退..."];
    [locationGetter startLocation];
}

- (void)sendRequestRemarkPicture
{
    EventModel *eventModel = [[EventModel alloc] init];
    eventModel.remark = commentTextView.text;
    eventModel.eventId = self.currentEventModel.eventId;
    EventsService * eventsService = [[EventsService alloc]init];
    [eventsService remarkPictureWithEvent:eventModel leftImageDate:imageViewOne.imageSetted?UIImageJPEGRepresentation(imageViewOne.image, 1.0):nil rightImageData:imageViewTwo.imageSetted?UIImageJPEGRepresentation(imageViewTwo.image, 1.0):nil];
}

- (void)sendRequestAttendanceSignIn
{
    EventsService *service = [[EventsService alloc] init];
    EventModel *eventModel = [[EventModel alloc] init];
    if (signLocationDictionary[@"latitude"]) {
        eventModel.signIn.latitude = [signLocationDictionary[@"latitude"] doubleValue];
    }
    if (signLocationDictionary[@"longitude"]) {
        eventModel.signIn.longitude = [signLocationDictionary[@"longitude"] doubleValue];
    }
    eventModel.validSign = self.vaildAttendanceSignIn?@"1":@"0";
    eventModel.signIn.location = signLocationDictionary[@"address"]?signLocationDictionary[@"address"]:@"";
    [service signInRequestWithEventModel:eventModel mapfileData:signLocationDictionary[@"mapImage"]];
}

-(void)sendRequestAttendanceSignOut
{
    EventsService *service = [[EventsService alloc] init];
    EventModel *eventModel = [[EventModel alloc] init];
    if (signLocationDictionary[@"latitude"]) {
        eventModel.signOut.latitude = [signLocationDictionary[@"latitude"] doubleValue];
    }
    if (signLocationDictionary[@"longitude"]) {
        eventModel.signOut.longitude = [signLocationDictionary[@"longitude"] doubleValue];
    }
    eventModel.signOut.location = signLocationDictionary[@"address"]?signLocationDictionary[@"address"]:@"";
    eventModel.eventId = self.currentEventModel.eventId;
//    [service signInRequestWithEventModel:eventModel mapfileData:signLocationDictionary[@"mapImage"]];
    [service signOutRequestWithEventModel:eventModel mapfileData:signLocationDictionary[@"mapImage"]];
}

- (void)sendRequestSignIn
{
    NSLog(@"enter 😄 😭");
    EventModel *eventModel = [[EventModel alloc] init];
    if (signLocationDictionary[@"latitude"]) {
        eventModel.signIn.latitude = [signLocationDictionary[@"latitude"] doubleValue];
    }
    if (signLocationDictionary[@"longitude"]) {
        eventModel.signIn.longitude = [signLocationDictionary[@"longitude"] doubleValue];
    }
    eventModel.signIn.location = signLocationDictionary[@"address"]?signLocationDictionary[@"address"]:@"";
    eventModel.eventItem.aimInfo = commentTextView.text;
    eventModel.eventName = eventNameField.text;
    UIButton *navBtn = (UIButton *)self.navigationItem.titleView;
    KeyValueModel *kvModel = [[KeyValueModel alloc] init];
    kvModel.modelName = navBtn.titleLabel.text;
    eventModel.eventType = kvModel;
    EventsService * eventsService = [[EventsService alloc]init];
    [eventsService easySignin:eventModel mapfileData:signLocationDictionary[@"mapImage"] leftimageData:imageViewOne.imageSetted?UIImageJPEGRepresentation(imageViewOne.image, 1.0):nil rightimageData:imageViewTwo.imageSetted?UIImageJPEGRepresentation(imageViewTwo.image, 1.0):nil];
}

- (void)attendanceSignInComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self saveLoginUserSignStatus:@1 WithSignType:SignType_In];
        [self backToHomePage];
    }
}

- (void)attendanceSignOutComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self saveLoginUserSignStatus:@1 WithSignType:SignType_Out];
        [self backToHomePage];
    }
}

-(void)signInComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self backToHomePage];
    }
}

- (void)sendRequestSignOut
{
    EventModel *eventModel = [[EventModel alloc] init];
    
    if (signLocationDictionary[@"latitude"]) {
        eventModel.signOut.latitude = [signLocationDictionary[@"latitude"] doubleValue];
    }
    if (signLocationDictionary[@"longitude"]) {
        eventModel.signOut.longitude = [signLocationDictionary[@"longitude"] doubleValue];
    }
    eventModel.signOut.location = signLocationDictionary[@"address"]?signLocationDictionary[@"address"]:@"";
    
    eventModel.eventItem.resultInfo = commentTextView.text;
    eventModel.eventId = self.currentEventModel.eventId;
    eventModel.eventName = eventNameField.text;
    EventsService * eventsService = [[EventsService alloc]init];
    [eventsService easySignOut:eventModel mapfileData:signLocationDictionary[@"mapImage"] leftimageData:imageViewOne.imageSetted?UIImageJPEGRepresentation(imageViewOne.image, 1.0):nil rightimageData:imageViewTwo.imageSetted?UIImageJPEGRepresentation(imageViewTwo.image, 1.0):nil];
}

-(void)signOutComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self backToHomePage];
    }
}

- (void)remarkPictureComplete:(NSNotification *)notification
{
    [self stopLoading];
    NSDictionary *dic = notification.userInfo;
    if ([self doResponse:dic]) {
        [self backToHomePage];
    }
}

- (void)deleteImageOnImageWall
{
    if (currentImageView) {
        currentImageView.image = [UIImage imageNamed:@"addImage"];
    }
    if ((imageViewOne.imageSetted == YES)&&(imageViewTwo.imageSetted == NO)) {
        currentImageView.imageSetted = NO;
        imageViewTwo.hidden = YES;
        [self verifyCanClickSendButton];
        return;
    }
    currentImageView.imageSetted = NO;
    [self moveImageOnImageViewTwoToImageViewOne];
    [self verifyCanClickSendButton];
}

- (void)moveImageOnImageViewTwoToImageViewOne
{
    if ([currentImageView isEqual:imageViewTwo]) {
        return;
    }
    if (imageViewTwo.hidden == NO) {
        imageViewOne.image = imageViewTwo.image;
    }
    imageViewOne.imageSetted = YES;
    imageViewTwo.imageSetted = NO;
    imageViewTwo.image = [UIImage imageNamed:@"addImage"];
    currentImageView = nil;
}

- (void)locationMessage:(NSNotification *)notif //获得了当前定位的坐标,地址
{
    NSDictionary *myDict = [notif userInfo];
    //    addressLabel.text = myDict[@"address"];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [myDict[@"latitude"] doubleValue];
    coordinate.longitude = [myDict[@"longitude"] doubleValue];
    [signLocationDictionary setObject:myDict[@"latitude"] forKey:@"latitude"];
    [signLocationDictionary setObject:myDict[@"longitude"] forKey:@"longitude"];
    [signLocationDictionary setObject:myDict[@"address"] forKey:@"address"];
    //在该处可以生成一个经纬度坐标
    locationUsing = YES;
    hasSetMaxMapZoomLevel = YES;
    if (ostMapView.annotations) {
        [ostMapView removeAnnotations:ostMapView.annotations];
    }
    
    [ostMapView setCenterCoordinate:coordinate zoomLevel:MAX_MAP_ZOOMLEVEL animated:NO];
    switch (self.mainFoundation) {
        case MAINFOUNDATION_SING_IN:
            [self showPointWithCoordinate:coordinate withTitle:@"signIn"];
            break;
        case MAINFOUNDATION_SING_OUT:
            [self showPointWithCoordinate:self.signedIncoordinate withTitle:@"signIn"];
            [self showPointWithCoordinate:coordinate withTitle:@"signOut"];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_IN:
            [self showPointWithCoordinate:coordinate withTitle:@"attendanceSignIn"];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_OUT:
            [self showPointWithCoordinate:self.signedIncoordinate withTitle:@"attendanceSignIn"];
            [self showPointWithCoordinate:coordinate withTitle:@"attendanceSignOut"];
            break;
        case MAINFOUNDATION_EDIT:
            break;
    }
}

- (void)snapMapOver:(NSNotification *)notif //获得了地图截图
{
    UIImage *img = [notif userInfo][@"img"];
    NSData *data = [OSTImageView compressImage:img];
    if (data == nil) {
        data = [NSData data];
    }
    [signLocationDictionary setObject:data forKey:@"mapImage"];
    [self freeLocationNotification];
    if (hasSendRequest == YES) {
        return;
    }
    hasSendRequest = YES;
    switch (self.mainFoundation) {
        case MAINFOUNDATION_SING_IN:
            [self sendRequestSignIn];
            break;
        case MAINFOUNDATION_SING_OUT:
            [self sendRequestSignOut];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_IN:
            [self sendRequestAttendanceSignIn];
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_OUT:
            [self sendRequestAttendanceSignOut];
            break;
        case MAINFOUNDATION_EDIT:
            break;
    }
}

- (void)setImageOnImageWallWithImageURLArray:(NSArray *)imageArray
{
    if (imageArray && imageArray.count == 1) {
        NSString *filename = imageArray[0];
        imageViewOne.imageSetted = YES;
        imageViewTwo.imageSetted = NO;
        imageViewOne.hidden = NO;
        imageViewTwo.hidden = NO;
        [self setImageToImageView:imageViewOne withFilename:filename];
    }
    else if (imageArray && imageArray.count == 2) {
        NSString *filename0 = imageArray[0];
        NSString *filename1 = imageArray[1];
        imageViewOne.imageSetted = YES;
        imageViewTwo.imageSetted = YES;
        imageViewOne.hidden = NO;
        imageViewTwo.hidden = NO;
        [self setImageToImageView:imageViewOne withFilename:filename0];
        [self setImageToImageView:imageViewTwo withFilename:filename1];
    }
}

-(void)setImageToImageView:(UIImageView *)imageView withFilename:(NSString *)filename
{
    EventsService *eventService = [[EventsService alloc]init];
    UIImage *fileimage = [eventService getImage:filename];
    NSURL * url = [eventService getDownloadImageUrl:filename];
    if (fileimage) {
        [imageView setImage:fileimage];
    }else{
        [imageView setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [eventService saveImage:image filename:filename];
        }];
    }
}
#pragma mark -
#pragma mark 界面操作
- (void)verifyCanClickSendButton
{
    if ((self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_IN) || (self.mainFoundation == MAINFOUNDATION_ATTENDANCE_SIGN_OUT)) {
        [self addRightButtonItemWithColor:rgbaColor(0, 122, 255, 1) AndSelectotr:@selector(sendButtonClick:)];
        return;
    }
    if ((eventNameField.text&& eventNameField.text.length>=2)||imageViewOne.imageSetted||(commentTextView.text&&commentTextView.text.length>=2)) {
        [self addRightButtonItemWithColor:rgbaColor(0, 122, 255, 1) AndSelectotr:@selector(sendButtonClick:)];
    }
    else
    {
        [self addRightButtonItemWithColor:[UIColor lightGrayColor] AndSelectotr:nil];
    }
}

- (void)showPointWithCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)atitle
{
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = coordinate;
    [ann setTitle:atitle];
    [ostMapView addAnnotation:ann];
}

- (void)addRightButtonItemWithColor:(UIColor *)color AndSelectotr:(SEL)sel
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:sel];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.tintColor = color;
}

- (void)showCanEditFieldOnTitle
{
    eventNameField.hidden = NO;
}


- (void)initSignContentCtrl
{
    if (CURRENT_VERSION < 7) {
        layoutTop.constant = 2;
    }
    [GraphicHelper convertRectangleToEllipses:commentTextView withBorderColor:[UIColor lightGrayColor] andBorderWidth:0.5f andRadius:3.f];
    [commentTextView installPlaceHolder:@"说些什么(500字内)..."];
    [imageViewOne registTapGestureShowImage];
    [imageViewTwo registTapGestureShowImage];
    
    [self registNotificationDeleteOSTImage];
    
    switch (self.mainFoundation) {
        case MAINFOUNDATION_EDIT:
            [self initImageWall];
            eventNameField.text = currentEventModel.eventName;
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_IN:
            {
                [self showMapViewOnMainVew];
                self.navigationItem.title = @"考勤签到";
            }
            break;
        case MAINFOUNDATION_ATTENDANCE_SIGN_OUT:
           {
               [self showMapViewOnMainVew];
               self.navigationItem.title = @"考勤签退";
           }
            break;
        case MAINFOUNDATION_SING_IN:
            {
                [self showCanEditFieldOnTitle];
                [self showNavigationTitle];
            }
            break;
        case MAINFOUNDATION_SING_OUT:
            {
                [self showCanEditFieldOnTitle];
                eventNameField.text = currentEventModel.eventName;
                [self showNavigationTitle];
            }
            break;
        default:
            break;
    }
    [self verifyCanClickSendButton];
    signLocationDictionary = [@{} mutableCopy];
    if (locationGetter) {
        locationGetter = nil;
    }
    locationGetter = [[LocationHelper alloc] init];
    [locationGetter initGPSLocation];
}

- (void)showNavigationTitle
{
    UIButton *navTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navTitleButton addTarget:self action:@selector(navTitleClick) forControlEvents:UIControlEventTouchUpInside];
    
    [navTitleButton setTitleColor:rgbaColor(0, 122, 255, 1) forState:UIControlStateNormal];
    if (self.currentEventModel) {
        [navTitleButton setTitle:self.currentEventModel.eventType.modelName forState:UIControlStateNormal];
    }
    else
    {
        [navTitleButton setTitle:@"外出拜访" forState:UIControlStateNormal];
    }
    self.navigationItem.titleView = navTitleButton;
    UIImageView *markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(72, 1, 6, 6)];
    markImageView.image = [UIImage imageNamed:@"pull-down.png"];
    [navTitleButton addSubview:markImageView];
}

- (void)showMapViewOnMainVew
{
    imageViewOne.hidden = YES;
    imageViewTwo.hidden = YES;
    commentTextView.hidden = YES;
    mapViewLayOutTop.constant = 0;
    [eventNameField removeFromSuperview];
}

- (void)initImageWall
{
    if (self.currentEventModel.remark&&(self.currentEventModel.remark.length>0)) {
        [commentTextView clearPlaceHolder];
        commentTextView.text = self.currentEventModel.remark;
    }
    [self setImageOnImageWallWithImageURLArray:self.currentEventModel.remarkModel.imageSource];
}

- (void)actionsheetShow
{
    [commentTextView resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    [actionSheet showInView:self.view];
}

- (void)clearOrInstallPlaceHolderWithTextView:(OSTTextView *)textView
{
    if ((textView.text.length == 0)||(textView.text == nil)) {
        [textView installPlaceHolder:@"说些什么(500字内)..."];
    }
    else
    {
        [textView clearPlaceHolder];
    }
}

#pragma mark -
#pragma mark 代理
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [views enumerateObjectsUsingBlock:^(MKPinAnnotationView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.annotation.title isEqualToString:@"signIn"]||[obj.annotation.title isEqualToString:@"attendanceSignIn"]) {
            obj.pinColor = MKPinAnnotationColorGreen;
        }
    }];
    if (locationUsing) {
        if (hasfullyRendered) {
            NSLog(@"渲染过了");
            [mapView getMapSnapShot];
        }
        else
        {
            if (CURRENT_VERSION <7) {
                hasfullyRendered = YES;
                [mapView performSelector:@selector(getMapSnapShot) withObject:self afterDelay:10.f];
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!locationUsing) {
        hasSetMaxMapZoomLevel = YES;
         [ostMapView setCenterCoordinate:ostMapView.userLocation.location.coordinate zoomLevel:MAX_MAP_ZOOMLEVEL animated:YES];
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    
    if (locationUsing) {
        if (hasfullyRendered == YES) {
            return;
        }
        NSLog(@"渲染完毕");
        [mapView getMapSnapShot];
    }
    if (hasSetMaxMapZoomLevel) {
        hasfullyRendered = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = [OSTImageView compressImage:pickerImage];
    currentImageView.image = [UIImage imageWithData:imageData];
    imageViewTwo.hidden = NO;
    currentImageView.imageSetted = YES;
    pickerImage = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];//退出照相机视图
    [self verifyCanClickSendButton];
}

- (void)textViewDidChange:(UITextView *)textView
{
    //编辑中
    if ([textView isMemberOfClass:[OSTTextView class]]) {
        OSTTextView *temp = (OSTTextView *)textView;
        [self clearOrInstallPlaceHolderWithTextView:temp];
    }
    if (textView.text.length>MAX_WORD_LENGTH) {
        textView.text = [textView.text substringToIndex:MAX_WORD_LENGTH];
    }
    [self verifyCanClickSendButton];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>MAX_WORD_LENGTH) {
        return NO;
    }
    char c = [text UTF8String][0];
    if (c=='\000') { //判断是否为删除字符
        return YES;
    }
    if (textView.text.length == MAX_WORD_LENGTH) {
        if (![text isEqualToString:@"\b"]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldChangedText
{
    [self verifyCanClickSendButton];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self startsystemImageLibrary];
            break;
        case 1:
            [self startCameraController];
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)signContentListSelectedTitle:(NSString *)title
{
    UIButton *tempBtn = (UIButton *)self.navigationItem.titleView;
    [tempBtn setTitle:title forState:UIControlStateNormal];
    [self removeTableList];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (signList) {
        [self removeTableList];
    }
}

#pragma mark - helper
- (void)backToHomePage
{
    NSString *Path = [self archiverFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] removeItemAtPath:Path error:nil];
    }
    needArchive = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 视图通知管理
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectOSTImage:) name:OSTIMAGEVIEW_PICKIMAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOSTImage:) name:OSTIMAGEVIEW_SHOWIMAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:SIGN_IN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOutComplete:) name:SIGN_OUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remarkPictureComplete:) name:REMARKPICTURE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attendanceSignInComplete:) name:ATTENDANCE_SIGN_IN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attendanceSignOutComplete:) name:ATTENDANCE_SIGN_OUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChangedText) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)registNotificationDeleteOSTImage
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteImageOnImageWall) name:IMAGESHOWVIEWCONTROLLER_DELETEIMAGE_NOTIFICATION object:nil];
}

- (void)registLocationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationMessage:) name:NOTIFICATION_LOCATION object:nil];  //该项负责接收地图定位之后的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snapMapOver:) name:NOTIFICATION_SNAP_MAPIMAGE_OVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationError) name:NOTIFICATION_LOCATION_ERROR object:nil];
}

- (void)freeNotificationDeleteOSTImage
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGESHOWVIEWCONTROLLER_DELETEIMAGE_NOTIFICATION object:nil];
}

-(void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OSTIMAGEVIEW_PICKIMAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OSTIMAGEVIEW_SHOWIMAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGN_IN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGN_OUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REMARKPICTURE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ATTENDANCE_SIGN_IN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ATTENDANCE_SIGN_OUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [self freeLocationNotification];
}

- (void)freeLocationNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SNAP_MAPIMAGE_OVER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION_ERROR object:nil];
}
@end
