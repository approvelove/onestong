//
//  FormViewController.m
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "FormViewController.h"



@interface FormViewController ()
{
    UIScrollView *tempScrollView;
}
@end

@implementation FormViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 公用接口
- (void)registFormScrollView:(UIScrollView *)scrollView
{
    if (tempScrollView) {
        tempScrollView = nil;
    }
    tempScrollView = scrollView;
}

#pragma mark -
#pragma mark 输入框代理
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (tempScrollView) {
        [self moveTextFieldUpWithTextField:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (tempScrollView) {
        [self reductionTextField:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark  界面处理
- (void)moveTextFieldUpWithTextField:(UITextField *)textField
{
    
    static float delta = 40; //输入框底部相对与键盘顶部的高度差值
    
    float text_bottom =  textField.frame.origin.y+[textField superview].frame.origin.y+textField.frame.size.height+delta;
    
    float keyboard_y = [[UIScreen mainScreen] bounds].size.height-KEYBOARD_HEIGHT;
    
    float content_height = tempScrollView.frame.size.height+KEYBOARD_HEIGHT/4+tempScrollView.frame.origin.y+delta;
    
    NSLog(@"heigt = %f",content_height);
    tempScrollView.contentSize = CGSizeMake(0, content_height);
    

    if (keyboard_y<= text_bottom) {
        float move_length = text_bottom-keyboard_y+tempScrollView.frame.origin.y;//要移动的距离
        [self doAnimationMoveWithView:tempScrollView newPoint:CGPointMake(tempScrollView.frame.origin.x,move_length)];
    }
}

- (void)reductionTextField:(UITextField *)textfield
{
    if (self.navigationController.navigationBarHidden == YES) {
        [self doAnimationMoveWithView:tempScrollView newPoint:tempScrollView.frame.origin];
    }
    else
    {
        [self doAnimationMoveWithView:tempScrollView newPoint:CGPointMake(tempScrollView.frame.origin.x, tempScrollView.frame.origin.y-64)];
    }
}

//视图动画
- (void)doAnimationMoveWithView:(UIScrollView *)root newPoint:(CGPoint)point
{
    //移动视图
    [root setContentOffset:point animated:YES];
}
@end
