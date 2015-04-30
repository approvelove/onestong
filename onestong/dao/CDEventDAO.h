//
//  CDEventDAO.h
//  onestong
//
//  Created by 李健 on 14-8-25.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FindType) {
    FindType_All = 3,
    FindType_Attendance = 1,
    FindType_Visit
};

@class CDEvent,EventModel;

@interface CDEventDAO : NSObject
+ (BOOL)save:(EventModel *)model;
+ (CDEvent *)findById:(NSString *)eventId;

+ (NSArray *)findByOwinerId:(NSString *)ownerId andDateStr:(NSString *)dateStr andSearchType:(FindType)type;
+ (NSDictionary *)findByOwinerId:(NSString *)ownerId andDateAry:(NSArray *)dateAry andSearchType:(FindType)type;

+ (BOOL)clearData;
+ (BOOL)deleteById:(NSString *)eventId;

+ (BOOL)update:(EventModel *)model;
@end
