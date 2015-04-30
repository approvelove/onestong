//
//  BaseViewController.m
//  onestong
//
//  Created by 王亮 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "TimeHelper.h"
#import "PGToast.h"
#import "UsersModel.h"

#define APP_WINDOW [[UIApplication sharedApplication] keyWindow]

@interface BaseViewController ()
{
    NSDictionary *HttpStautsCodedict;
}
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToRootViewController) name:VERSION_CHECK_NOTIFICATION object:nil];
    [self inputHttpStatusCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 通用操作

- (void)showAlertwithTitle:(NSString *)titleStr
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:titleStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (NSString *)getRequestStatusWithCode:(NSString *)code
{
    NSString *message = [HttpStautsCodedict objectForKey:code];
    return message;
}

- (void)startLoading:(NSString *)labelText
{
    [[MBProgressHUD showHUDAddedTo:APP_WINDOW animated:YES] setLabelText:labelText];
}

- (void)inputHttpStatusCode
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"HttpStatus" ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:plistPath]) {
        HttpStautsCodedict = [NSDictionary dictionaryWithContentsOfFile:plistPath];//从指定路径读出
    }
    else
    {
        NSLog(@"local storage don't have cache");
    };
}

- (void)startLoading
{
    [self startLoading:@"正在加载"];
}

- (void)stopLoading
{
    [MBProgressHUD hideHUDForView:APP_WINDOW animated:YES];
}


#pragma mark -
#pragma mark 通用响应处理
- (id)doResponse:(NSDictionary *)resultDictionary
{
    if (resultDictionary) {
        NSString *code = resultDictionary[@"resultCode"];
        NSString *title = [self getRequestStatusWithCode:code];
        if ([title isEqualToString:@"success"]) {
            NSLog(@"😄");
            if ([resultDictionary[@"resultData"] isKindOfClass:[NSDictionary class]] ||[resultDictionary[@"resultData"] isKindOfClass:[NSArray class]]) {
                if (!resultDictionary[@"resultData"]||[resultDictionary[@"resultData"] count]==0) {
                    return nil;
                }
            }
            return resultDictionary[@"resultData"];
        }
        else
        {
            NSString *resultDescription = resultDictionary[@"resultDescription"];
            NSString *message = [self getRequestStatusWithCode:resultDescription];
            [self showAlertwithTitle:message];
        }
    }
    else
    {
        [self showAlertwithTitle:@"😓～～ 加载失败啦!!!"];
    }
    return nil;
}

-(void)saveLoginUserSignStatus:(NSNumber *)signStatus WithSignType:(SignType)type
{
    //format @{@"hasSignIn":@1,@"hasSignOut":@"1"}; 1已签到 0 未签到
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    switch (type) {
        case SignType_In:
        {
            [defaults setObject:signStatus forKey:@"hasSignIn"];
            NSDateComponents *com = [TimeHelper getDateComponents];
            [defaults setObject:[NSNumber numberWithInteger:com.day] forKey:@"dayValue"];
        }
            break;
        case SignType_Out:
        {
            [defaults setObject:signStatus forKey:@"hasSignOut"];
        }
            break;
    }
    [defaults synchronize];
}


- (NSNumber *)getLoginUserSignStatusWithType:(SignType)type
{
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSDateComponents *com = [TimeHelper getDateComponents];
    if (![[defaults objectForKey:@"dayValue"] isEqualToNumber:[NSNumber numberWithInteger:com.day]]) {
        return @0;
    }
    switch (type) {
        case SignType_In:
            {
                NSNumber *temp = [defaults objectForKey:@"hasSignIn"];
                return temp;
            }
            break;
            
        case SignType_Out:
            {
                NSNumber *temp = [defaults objectForKey:@"hasSignOut"];
                return temp;
            }
            break;
    }
    return nil;
}

- (void)showRoot
{
    NSLog(@"className = %@",NSStringFromClass([self class]));
    if (self) {
        if ([NSStringFromClass([self class]) isEqualToString:@"LoginViewController"]) {
            return;
        }
        if (self.navigationController) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        else
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)backToRootViewController
{
    [self showRoot];
}

-(void)toast:(NSString *)str
{
    if(str == nil || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  isEqual: @""])
    {
        return;
    }
    PGToast *toast = [PGToast makeToast:str];
    [toast show];
}

@end
