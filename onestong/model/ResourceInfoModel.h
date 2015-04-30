//
//  ResourceInfoModel.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceInfoModel : NSObject
@property(nonatomic)long long createTime; //ti 创建时间
@property(copy, nonatomic)NSString *pictureUrl; //ur 资源地址
@property(nonatomic)double longitude; //lo 经度
@property(nonatomic)double latitude; //la 纬度
@property(copy, nonatomic)NSString *location; //lc 位置
@property(copy, nonatomic)NSString *content; //co 内容
@property(copy, nonatomic)NSString *eventId;
@property(nonatomic) BOOL isSignIn;

-(ResourceInfoModel *)fromDictionary: (NSDictionary *)obj;
@end
