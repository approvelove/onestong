//
//  EventsService.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseService.h"

typedef NS_ENUM(NSInteger, SearchType) {
    SearchType_All = 3,
    SearchType_Attendance = 1,
    SearchType_Visit
};

@class EventModel;

static NSString * const FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION = @"findSomedayOwnSignEventsNotification";
static NSString * const SIGN_IN_NOTIFICATION = @"signInNotification";
static NSString * const SIGN_OUT_NOTIFICATION = @"signOutNotification";
static NSString * const REMARKPICTURE_NOTIFICATION = @"remark picture notification";
static NSString * const ATTENDANCE_SIGN_IN_NOTIFICATION = @"attendance sign in notification post";
static NSString * const ATTENDANCE_SIGN_OUT_NOTIFICATION = @"attendance sign out notification post";
static NSString * const VERIFY_ATTENDANCE_SIGN_IN_NOTIFICATION = @"verify attendance sign in notificaton post";
static NSString * const FIND_EVENT_LIST_NOTIFICATION = @"find event list notification";


@interface EventsService : BaseService

-(void)findSomedayOwnSignEvents:(NSString *)date andUser:(UsersModel *)user andSearchType:(SearchType)typeValue;

-(void)saveImage:(UIImage *)image filename:(NSString *)filename;

-(UIImage *)getImage:(NSString *)filename;

-(NSURL *)getDownloadImageUrl:(NSString *)filename;

/**
 *	@brief	拜访事件签到
 *
 *	@param 	event 	事件
 *	@param 	mapfileData 	当前地理位置截图
 *	@param 	leftimageData 	图片1
 *	@param 	rightimageData 	图片2
 *
 *	@return	nil
 */
-(void)easySignin:(EventModel *)event mapfileData:(NSData *)mapfileData leftimageData:(NSData *)leftimageData rightimageData:(NSData *)rightimageData;


/**
 *	@brief	拜访事件签退
 *
 *	@param 	event 	事件
 *	@param 	mapfileData 	当前地理位置截图
 *	@param 	leftimageData 	图片1
 *	@param 	rightimageData 	图片2
 *
 *	@return	nil
 */
-(void)easySignOut:(EventModel *)event mapfileData:(NSData *)mapfileData leftimageData:(NSData *)leftimageData rightimageData:(NSData *)rightimageData;


- (void)remarkPictureWithEvent:(EventModel *)event leftImageDate:(NSData *)leftImageData rightImageData:(NSData *)rightImageData;

//考勤事件签到
- (void)signInRequestWithEventModel:(EventModel *)event mapfileData:(NSData *)mapfileData;

//考勤事件签退
- (void)signOutRequestWithEventModel:(EventModel *)event mapfileData:(NSData *)mapfileData;

//校验
- (void)verifyHasAttendanceSignIn;

- (void)findEventList;
@end
