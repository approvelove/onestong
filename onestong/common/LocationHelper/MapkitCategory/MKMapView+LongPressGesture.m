//
//  MKMapView+TapGesture.m
//  MyTest
//
//  Created by 李健 on 14-3-5.
//  Copyright (c) 2014年 李健. All rights reserved.
//

#import "MKMapView+LongPressGesture.h"

@implementation MKMapView (LongPressGesture)

static bool longPressing = NO;
static id alertViewdelegate;
static CLLocationCoordinate2D touchMapCoordinate;
- (void)addLongPressGesture
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UILongPressGestureRecognizer *mTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:mTap];
    });
}

- (void)longPress:(UIGestureRecognizer *)gesture
{
    if (longPressing == YES) {
        return;
    }
    longPressing = YES;
    CGPoint touchPoint = [gesture locationInView:self];//这里touchPoint是点击的某点在地图控件中的地位
    touchMapCoordinate =[self convertPoint:touchPoint toCoordinateFromView:self];//这里touchMapCoordinate就是该点的经纬度了
//    NSLog(@"touchPoint x= %f, y= %f",touchPoint.x,touchPoint.y);
    [self showAlertToConfirmAddPointAnnotation];
}

- (void)setAlertViewDelegate:(id)delegate
{
    alertViewdelegate = delegate;
}
- (void)showAlertToConfirmAddPointAnnotation
{
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"您是否要在此处插针" delegate:alertViewdelegate cancelButtonTitle:@"取消" otherButtonTitles:@"插针", nil];
    
    [alert show];
    longPressing = NO;
}

- (void)showPointAnnotationWithTitle:(NSString *)title
{
    MKPointAnnotation *ann = [MKMapView sharedPointAnnitation];
    ann.coordinate = touchMapCoordinate;
    ann.title = title;
    
    //触发viewForAnnotation
    [self addAnnotation:ann];
    [self setMapCenterWithCoordinate:touchMapCoordinate];
}

- (void)setMapCenterWithCoordinate:(CLLocationCoordinate2D)coordinate
{
 
    [self setCenterCoordinate:coordinate zoomLevel:20 animated:YES];
}

//截取地图
- (void)getMapSnapShot
{
    float  versionData = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (versionData < 7) {
        [self snapShotOniOS6];
        return;
    }
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.region;
    options.size = self.frame.size;
    options.showsPointsOfInterest = YES;
    options.scale = [[UIScreen mainScreen] scale];
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [self addPinAnnotationOnSnapShotter:snapshotter];
}

- (void)snapShotOniOS6
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SNAP_MAPIMAGE_OVER object:nil userInfo:@{@"img":image}];
}

- (void)addPinAnnotationOnSnapShotter:(MKMapSnapshotter *)snapShotter
{
    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        UIImage *snapShotImage = snapshot.image;
        CGRect finalImageRect = CGRectMake(0, 0, snapShotImage.size.width, snapShotImage.size.height);
        UIGraphicsBeginImageContextWithOptions(snapShotImage.size, YES, snapShotImage.scale);
        [snapShotImage drawAtPoint:CGPointMake(0, 0)];
        for (id<MKAnnotation>annotation in self.annotations)
        {
            MKAnnotationView *pin = [self viewForAnnotation:annotation];
            UIImage *pinImage = pin.image;
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                [pinImage drawAtPoint:point];
            }
        }
      UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (finalImage == nil) {
            finalImage = [[UIImage alloc] init];
        }
      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SNAP_MAPIMAGE_OVER object:nil userInfo:@{@"img":finalImage}];
//        UIImageWriteToSavedPhotosAlbum(finalImage, self, nil, NULL);
    }];
}


+ (MKPointAnnotation *)sharedPointAnnitation
{
    static MKPointAnnotation *ann;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            ann = [[MKPointAnnotation alloc] init];
    });
    return ann;
}

@end
