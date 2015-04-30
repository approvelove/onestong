//
//  MapPathViewController.m
//  onestong
//
//  Created by 李健 on 14-6-9.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "MapPathViewController.h"
#import "EventsService.h"
#import "UsersModel.h"
#import "MKMapView+ZoomLevel.h"
#import "EventModel.h"
#import "TimeHelper.h"
#import "DeviceTraceModel.h"
#import "DeviceTraceService.h"

@interface MapPathViewController ()<MKMapViewDelegate>
{
    NSMutableArray *dataSource;
    __weak IBOutlet MKMapView *ostMapView;
    MKPolyline *routeLine;
    MKPolylineView *routeLineView;
}
@end

@implementation MapPathViewController
@synthesize showDate,currentUser,currentShow;

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
    [self registNotification];
    switch (self.currentShow) {
        case SHOWPOINT_EVENT:
            [self sendRequestGetNewSignDetailData];
            break;
        case SHOWPOINT_DEVICE:
            [self sendRequestGetDeviceInfo];
        default:
            break;
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

#pragma mark - 事件处理

#pragma mark - 逻辑处理

- (void)sendRequestGetDeviceInfo
{
    DeviceTraceService *service = [[DeviceTraceService alloc] init];
    [service findDeviceTraceWithUser:self.currentUser withDate:self.showDate];
}

- (void)sendRequestGetNewSignDetailData
{
    EventsService *eventeService = [[EventsService alloc] init];
    [eventeService findSomedayOwnSignEvents:self.showDate andUser:self.currentUser andSearchType:SearchType_All];
}

- (void)findSomeDayDeviceTraceComplete:(NSNotification *)notification
{
    NSArray *arrInfo = [self doResponse:notification.userInfo];
    NSMutableArray *timeSortAry = [NSMutableArray array];
    if (arrInfo) {
        for (int i = 0; i<[arrInfo count]; i++) {
            DeviceTraceModel *deviceModel = arrInfo[i];
            CLLocationCoordinate2D coordinate =  CLLocationCoordinate2DMake(deviceModel.latitude, deviceModel.longtitude);
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.coordinate = coordinate;
            NSDateComponents *comps = [TimeHelper convertTimeToDateComponents:deviceModel.createTime];
            ann.title = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)comps.year,(long)comps.month,(long)comps.day,(long)comps.hour,(long)comps.minute,(long)comps.second];
            ann.subtitle = deviceModel.location;
            if (coordinate.longitude !=0 && coordinate.latitude !=0) {
                [self addPointAnnOnMapView:ann];
            }
            NSDictionary *dicSignIn = @{@"pointAnnotation":ann,@"time":[NSString stringWithFormat:@"%lld",deviceModel.createTime]};
            [timeSortAry addObject:dicSignIn];
        }
        
        //循环完毕
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        timeSortAry  = [[timeSortAry sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]] mutableCopy];
        [self showLineOnMapWithSortAry:timeSortAry];
    }
}

- (void)findSomeDayOwnSignEventComplete:(NSNotification *)notification
{
    NSDictionary * dic = notification.userInfo;
    NSMutableArray *timeSortAry = [NSMutableArray array];
    
    if ([self doResponse:dic]) {
        NSMutableArray *tempAry = dic[@"resultData"];
        if (!tempAry||[tempAry count]==0) {
            return;
        }
        for (int i = 0; i<[tempAry count]; i++) {
            EventModel *event = tempAry[i];
            CLLocationCoordinate2D coordinateIn =  CLLocationCoordinate2DMake(event.signIn.latitude, event.signIn.longitude);
            MKPointAnnotation *annIn = [[MKPointAnnotation alloc] init];
            annIn.coordinate = coordinateIn;
            NSDateComponents *compsIn = [TimeHelper convertTimeToDateComponents:event.signIn.createTime];
            annIn.title = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)compsIn.year,(long)(long)compsIn.month,(long)compsIn.day,(long)compsIn.hour,(long)compsIn.minute,(long)compsIn.second];
            annIn.subtitle = event.signIn.location;
            if (coordinateIn.longitude !=0 && coordinateIn.latitude !=0) {
                [self addPointAnnOnMapView:annIn];
            }
            NSDictionary *dicSignIn = @{@"pointAnnotation":annIn,@"time":[NSString stringWithFormat:@"%lld",event.signIn.createTime]};
            [timeSortAry addObject:dicSignIn];
            
            CLLocationCoordinate2D coordinateOut = CLLocationCoordinate2DMake(event.signOut.latitude, event.signOut.longitude);
            MKPointAnnotation *annOut = [[MKPointAnnotation alloc] init];
            annOut.coordinate = coordinateOut;
            NSDateComponents *compsOut = [TimeHelper convertTimeToDateComponents:event.signOut.createTime];
            annOut.title = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)compsOut.year,(long)compsOut.month,(long)compsOut.day,(long)compsOut.hour,(long)compsOut.minute,(long)compsOut.second];
            annOut.subtitle = event.signOut.location;
            NSDictionary *dicSignOut = @{@"pointAnnotation":annOut,@"time":[NSString stringWithFormat:@"%lld",event.signOut.createTime]};
            if (coordinateOut.longitude !=0 && coordinateOut.latitude !=0) {
                [self addPointAnnOnMapView:annOut];
            }
            [timeSortAry addObject:dicSignOut];
        }
        
        //循环完毕
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        timeSortAry  = [[timeSortAry sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]] mutableCopy];
        [self showLineOnMapWithSortAry:timeSortAry];
    }
}

- (void)showLineOnMapWithSortAry:(NSArray *)sortAry
{
    if (!sortAry) {
        return;
    }
    NSMutableArray *locationAry = [@[] mutableCopy];
    for (int i=0; i<[sortAry count]; i++) {
        MKPointAnnotation *ann = sortAry[i][@"pointAnnotation"];
        CLLocation *temp = [[CLLocation alloc] initWithLatitude:ann.coordinate.latitude longitude:ann.coordinate.longitude];
        if (temp.coordinate.latitude !=0 && temp.coordinate.longitude != 0) {
            [locationAry addObject:temp];
        }
    }
    if ([locationAry count]>0) {
        [self drawLineWithLocationArray:locationAry];
    }
}

- (void)addPointAnnOnMapView:(MKPointAnnotation *)ann
{
    if (ann) {
        [ostMapView addAnnotation:ann];
    }
}


- (void)drawLineWithLocationArray:(NSArray *)locationArray
{
    int pointCount = [locationArray count];
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc(pointCount * sizeof(CLLocationCoordinate2D));
    
    
    NSMutableArray *annAry = [@[] mutableCopy];
    for (int i = 0; i < pointCount; ++i) {
        CLLocation *location = [locationArray objectAtIndex:i];
        coordinateArray[i] = [location coordinate];
        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
        ann.coordinate = location.coordinate;
        [annAry addObject:ann];
    }
    routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:pointCount];
    [ostMapView setVisibleMapRect:[routeLine boundingMapRect]];
    [ostMapView addOverlay:routeLine];
    
    //此时要注意顺序
    [ostMapView showAllPointPinOnMapWithPointArrary:annAry];
    free(coordinateArray);
    coordinateArray = NULL;
}
#pragma mark - 代理
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == routeLine) {
        if(nil == routeLineView) {
            routeLineView = [[MKPolylineView alloc] initWithPolyline:routeLine];
            routeLineView.fillColor = [UIColor redColor];
            routeLineView.strokeColor = [UIColor redColor];
            routeLineView.lineWidth = 5;
        }
        return routeLineView;
    }
    return nil;
}
#pragma mark - 界面处理

- (void)showPointWithCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)atitle
{
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = coordinate;
    [ann setTitle:atitle];
    [ostMapView addAnnotation:ann];
}
#pragma mark - 通知管理
- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findSomeDayOwnSignEventComplete:) name:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findSomeDayDeviceTraceComplete:) name:FIND_DEVICE_IN_DATE_NOTIFICATION object:nil];
    
}

- (void)freeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIND_DEVICE_IN_DATE_NOTIFICATION object:nil];
}
@end
