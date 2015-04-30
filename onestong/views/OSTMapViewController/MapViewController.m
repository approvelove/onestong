//
//  MapViewController.m
//  Transaction
//
//  Created by 李健 on 14-3-28.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "MapViewController.h"
#import "OSTMapInfo.h"

@interface MapViewController ()<MKMapViewDelegate>
{
    __weak IBOutlet MKMapView *ostMapView;
    __weak IBOutlet NSLayoutConstraint *layoutTop;
}
@end

@implementation MapViewController
@synthesize pointViewAry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initMapView
{
    if (CURRENT_VERSION<7) {
        layoutTop.constant = 0;
    }
    NSMutableArray *pointAry = [NSMutableArray array];
    if (self.pointViewAry) {
        for (int i=0; i<[self.pointViewAry count]; i++) {
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            
            OSTMapInfo *obj = [self.pointViewAry objectAtIndex:i];
            ann.coordinate = obj.pinAnnotation.annotation.coordinate;
            if (obj.pinAnnotation.pinColor == MKPinAnnotationColorGreen) {
                ann.title = @"签到";
            }
            else if (obj.pinAnnotation.pinColor == MKPinAnnotationColorRed)
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
                annView.pinColor = MKPinAnnotationColorGreen;
            }
            else
            {
                annView.pinColor = MKPinAnnotationColorRed;
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initMapView];
}

- (void)returnTofrontpage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
