//
//  CDEventItemDAO.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDEventItem,EventItemModel;

@interface CDEventItemDAO : NSObject

+ (BOOL)save:(EventItemModel *)model;
+ (CDEventItem *)findById:(NSString *)eventId;
+ (BOOL)clearData;
+(BOOL)deleteById:(NSString *)eventId;

+ (BOOL)update:(EventItemModel *)model;
@end
