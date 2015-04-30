//
//  TimeHelper.h
//  Transaction
//
//  Created by 李健 on 13-12-25.
//  Copyright (c) 2013年 李健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeHelper : NSObject

/**
 *	@brief	获取当前时间的日期详细
 *
 *	@return	返回当前日期的详细信息
 */
+ (NSDateComponents *)getDateComponents;

+ (NSDateComponents *)getDateComponentsWithDate:(NSDate *)date;

+ (NSDateComponents *)convertTimeToDateComponents:(long long)time;

+ (long long)convertDateToSecondTime:(NSDate *)date;


+ (NSDate *)convertSecondsToDate:(long long)time;

+ (NSMutableArray *)getNextPageDays:(int)page;

+ (NSString *)getWeekDayInweekWithDate:(NSDate *)date;
/**
 *	@brief	获取当前日期所在周的周一
 *
 *	@param 	date 	要查询的日期
 *
 *	@return	该日期所在周的周一
 */
+ (NSDate *)getBeginDateInWeekWith:(NSDate *)date;

/**
 *	@brief	获取当前日期的前一天
 *
 *	@param 	date 	要查询的日期
 *
 *	@return	该日期的前一天
 */
+ (NSDate *)getYesterDay:(NSDate *)date;

/**
 *	@brief	获取当前日期所在周的周日
 *
 *	@param 	date 	要查询的日期
 *
 *	@return	该日期所在周的周日
 */
+ (NSDate *)getEndDateInWeekWithDate:(NSDate *)date;

/**
 *	@brief	获取当前日期所在周上周的周日
 *
 *	@param 	date 	要查询的日期
 *
 *	@return	该日期所在周上周的周日
 */
+ (NSDate *)getlastWeekDayDateWithDate:(NSDate *)date;

/**
 *	@brief	获取当前日期所在周上周的周一
 *
 *	@param 	date 	要查询的日期
 *
 *	@return	该日期所在周上周的周一
 */
+ (NSDate *)getlastFirstDayDateWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期所在月的第一天
 *
 *	@param 	date 	当前日期
 *
 *	@return	日期
 */
+ (NSDate *)getFirstDayDateInCurrentDateMonthWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期所在月的最后一天
 *
 *	@param 	date 	当前日期
 *
 *	@return	日期
 */
+ (NSDate *)getEndDayDateInCurrentDateMonthWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期所在月的上月的最后一天
 *
 *	@param 	date 	当前日期
 *
 *	@return	日期
 */
+ (NSDate *)getEndDayDateInLastMonthOfDateWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期所在月的上月的第一天
 *
 *	@param 	date 	当前日期
 *
 *	@return	日期
 */
+ (NSDate *)getFirstDayDateInLastMonthOfDateWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期的年-月-日
 *
 *	@param 	date 	当前日期
 *
 *	@return	@"年-月-日"
 */
+ (NSString *)getYearMonthDayWithDate:(NSDate *)date;

/**
 *	@brief	返回当前日期的XXXX年XX月XX日
 *
 *	@param 	date 	当前日期
 *
 *	@return	XXXX年XX月XX日
 */
+ (NSString *)getYearMonthDayWithDateInChinese:(NSDate *)date;

/**
 *	@brief	字符串转换成日期 目前只支持xxxx-xx-xx格式
 *
 *	@param 	str 	日期字符串
 *
 *	@return	date
 */
+ (NSDate *)dateFromString:(NSString *)str;

+ (NSDate *)timeFromString:(NSString *)str andFormat:(NSString *)format;
@end
