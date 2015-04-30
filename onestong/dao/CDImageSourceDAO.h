//
//  CDImageSourceDAO.h
//  onestong
//
//  Created by 李健 on 14-8-27.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDImageSource;

@interface CDImageSourceDAO : NSObject
+ (BOOL)save:(NSString *)url;
+ (CDImageSource *)findByName:(NSString *)name;
+ (BOOL)clearData;
+(BOOL)deleteByName:(NSString *)name;
@end
