//
//  BaseViewController.h
//  onestong
//
//  Created by 王亮 on 14-4-22.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SignType) {
    SignType_In,
    SignType_Out
};

@interface BaseViewController : UIViewController
- (void)startLoading:(NSString *)labelText;
- (void)startLoading;
- (void)stopLoading;

-(void)saveLoginUserSignStatus:(NSNumber *)signStatus WithSignType:(SignType)type;
- (NSNumber *)getLoginUserSignStatusWithType:(SignType)type;

- (void)showAlertwithTitle:(NSString *)titleStr;
- (NSString *)getRequestStatusWithCode:(NSString *)code;
- (id)doResponse:(NSDictionary *)resultDictionary;
- (void)showRoot;
- (void)toast:(NSString *)str;
@end
