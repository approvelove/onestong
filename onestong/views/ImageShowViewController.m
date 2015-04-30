//
//  ImageShowViewController.m
//  onestong
//
//  Created by 李健 on 14-4-26.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "ImageShowViewController.h"

@interface ImageShowViewController ()
{
    __weak IBOutlet UIImageView *screenImageView;
}
@end

@implementation ImageShowViewController

@synthesize screenimage,deletButtonHidden;

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
    [self initImageShowViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark 界面事件处理
- (void)tap:(UIGestureRecognizer *)gesture
{
    if (self.navigationController.navigationBarHidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)deleteImageView:(id)sender
{
    NSLog(@"删除");
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGESHOWVIEWCONTROLLER_DELETEIMAGE_NOTIFICATION object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark 界面逻辑处理

- (CGSize)setImgSize:(UIImage *)image
{
    CGSize resultSize = CGSizeZero;
    UIImageView *testFrame = [[UIImageView alloc] initWithImage:image];
    
    float realWidth = testFrame.frame.size.width;
    float realHeight = testFrame.frame.size.height;
    float maxH = [[UIApplication sharedApplication] keyWindow].frame.size.height;
    float maxV = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    if (realHeight>maxH) {
        realWidth = (realWidth/realHeight)*maxH;
        realHeight = maxH;
    }
    if (realWidth>maxV) {
        realHeight = realHeight*(maxV/realWidth);
        realWidth = maxV;
    }
    resultSize = CGSizeMake(realWidth, realHeight);
    return resultSize;
}

#pragma mark -
#pragma mark 界面操作
- (void)initImageShowViewController
{
    screenImageView.image = self.screenimage;
    if (self.deletButtonHidden == NO) {
        [self addRightButtonItem];
    }
    [self registTapGesture];
}

- (void)registTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [screenImageView addGestureRecognizer:tapGesture];
}

- (void)addRightButtonItem
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bin"] style:UIBarButtonItemStyleBordered target:self action:@selector(deleteImageView:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark -
#pragma mark 通知管理


@end
