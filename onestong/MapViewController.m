//
//  MapViewController.m
//  Transaction
//
//  Created by 李健 on 14-3-28.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "MapViewController.h"
#import "OZSerialView.h"
#import "OSTMapInfo.h"

@interface MapViewController ()<MKMapViewDelegate>
{
    MKMapView *ostMapView;
}
@end

@implementation MapViewController
@synthesize coordinate,address,pointViewAry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initMapViewWithOriginY:(float)origin_y
{
    if (ostMapView) {
        [ostMapView removeFromSuperview];
        ostMapView = nil;
    }
    ostMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, origin_y,
                                                            [[UIApplication sharedApplication] keyWindow].frame.size.width,
                                            [[UIApplication sharedApplication] keyWindow].frame.size.height-origin_y)]; //继承自scrolview
    ostMapView.mapType = MKMapTypeStandard;  //设置地图类型
    ostMapView.showsUserLocation = NO;//定位自己,在地图上是用蓝点表示的
    ostMapView.zoomEnabled = YES;//用户可以收缩、拖动和其他方式与显示的地图进行交互
    ostMapView.scrollEnabled = YES;
    ostMapView.delegate = self;
    [self.view addSubview:ostMapView];
    
    NSMutableArray *pointAry = [NSMutableArray array];
    if (self.pointViewAry) {
        for (int i=0; i<[self.pointViewAry count]; i++) {
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            
            OSTMapInfo *obj = [self.pointViewAry objectAtIndex:i];
            ann.coordinate = obj.pinAnnotation.annotation.coordinate;
            if (obj.pinAnnotation.pinColor == MKPinAnnotationColorRed) {
                ann.title = @"签到";
            }
            else if (obj.pinAnnotation.pinColor == MKPinAnnotationColorGreen)
            {
                ann.title = @"签退";
            }
            ann.subtitle = obj.address;
            //触发viewForAnnotation
            [ostMapView addAnnotation:ann];
            [pointAry addObject:ann];
        }
    }
    
    [ostMapView showAllPointPinOnMapWithPointArrary:pointAry];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (int i=0; i<[views count]; i++) {
        MKPinAnnotationView *annView = [views objectAtIndex:i];
        if ([annView isMemberOfClass:[MKPinAnnotationView class]]) {
            if ([@"签到" isEqual:annView.annotation.title]) {
                annView.pinColor = MKPinAnnotationColorRed;
            }
            else
            {
                annView.pinColor = MKPinAnnotationColorGreen;
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int version = [[[UIDevice currentDevice] systemVersion] floatValue];
    float ozbutY = 0;
    if (version>=7) {
        ozbutY = 20;
        UIImageView *topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ozbutY)];
        topImage.backgroundColor = [UIColor colorWithRed:68.f/255.f green:68.f/255.f blue:68.f/255.f alpha:1.f];
        [self.view addSubview:topImage];
    }
    //加载navigationBar
    OZTopBar *nav_Bar= [OZTopBar loadFromNib];
    nav_Bar.frame = CGRectMake(0, ozbutY, nav_Bar.frame.size.width, nav_Bar.frame.size.height);
    nav_Bar.titlelabel.text = @"大图";
    nav_Bar.titlelabel.textAlignment = NSTextAlignmentCenter;
    nav_Bar.titlelabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nav_Bar];
    
    OZButton *ozbackButton = [OZButton loadFromNib];
    float oz_button_x = 8.f;
    float oz_button_y = 14.f;
    ozbackButton.frame  = CGRectMake(oz_button_x, oz_button_y, ozbackButton.frame.size.width, ozbackButton.frame.size.height);
    ozbackButton.titleLabel.text = @"返回";
    [ozbackButton addTarget:self action:@selector(returnTofrontpage:)];
    [nav_Bar addSubview:ozbackButton];
    
    [self initMapViewWithOriginY:nav_Bar.frame.size.height+nav_Bar.frame.origin.y];
}

- (void)returnTofrontpage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded]&&(![self.view window])) {
        [ostMapView removeFromSuperview];
        ostMapView = nil;
        self.pointViewAry = nil;
        self.address = nil;
        self.view = nil;
    }
    // Dispose of any resources that can be recreated.
}

@end
