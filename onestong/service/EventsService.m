//
//  EventsService.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "EventsService.h"
#import "CommonHelper.h"
#import "EventModel.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "CDEventDAO.h"

@implementation EventsService
- (void)findEventList
{
    NSString *urlStr = [NSString stringWithFormat:@"%@eventType/%@",BASE_URL,[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FIND_EVENT_LIST_NOTIFICATION object:nil userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FIND_EVENT_LIST_NOTIFICATION object:nil userInfo:nil];
    }];
}

-(void)findSomedayOwnSignEvents:(NSString *)date andUser:(UsersModel *)user andSearchType:(SearchType)typeValue
{
    NSString * findSomedayOwnSignEventsUrl = nil;
    if (!user) {
       findSomedayOwnSignEventsUrl = [NSString stringWithFormat:@"%@events/someday/%@/%@/%@/%d",BASE_URL, date, [self getOwnId], [self getToken],(int)typeValue];
    }
    else
    {
        findSomedayOwnSignEventsUrl = [NSString stringWithFormat:@"%@events/someday/%@/%@/%@/%d",BASE_URL, date, user.userId, [self getToken],(int)typeValue];
    }
    
    [[AFHTTPRequestOperationManager manager]GET:findSomedayOwnSignEventsUrl parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary * responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        NSMutableArray * resultArr = [@[]mutableCopy];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSArray *arrEvents =responseObject[@"resultData"];
            if (arrEvents) {
                [arrEvents enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                    EventModel *event = [[EventModel alloc]init];
                    event = [event fromDictionary:obj];
                    CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
                    if (!tempCDEvent) {
                        [CDEventDAO save:event];
                    }
                    else
                    {
                        [CDEventDAO update:event];
                    }
                    [resultArr addObject:event];
                }];
            }
        }
        [CommonHelper postNotification:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":resultArr}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:FIND_SOMEDAY_OWN_SIGN_EVENTS_NOTIFICATION userInfo:nil];
    }];
}

-(void)easySignin:(EventModel *)event mapfileData:(NSData *)mapfileData leftimageData:(NSData *)leftimageData rightimageData:(NSData *)rightimageData
{
    UsersModel * currentUser = [self getCurrentUser];
    
    NSDictionary *location = @{@"lo":[NSString stringWithFormat:@"%f", event.signIn.longitude], @"la":[NSString stringWithFormat:@"%f", event.signIn.latitude], @"lc":event.signIn.location?event.signIn.location:@""};
    
    NSDictionary *sign_dict = @{@"ty":@{@"ud":@"2",@"na":event.eventType.modelName?event.eventType.modelName:@""}, @"pu":@{@"ud":currentUser.userId,@"na":currentUser.username?currentUser.username:@""}, @"ow":@{@"ud":currentUser.userId,@"na":currentUser.username?currentUser.username:@""}, @"si":location, @"cr":currentUser.username?currentUser.username:@"",@"na":event.eventName?event.eventName:@""};
    
    NSData *da = [NSJSONSerialization dataWithJSONObject:sign_dict options:NSJSONWritingPrettyPrinted error:Nil];
    NSString *strrr = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    
    NSString * easySignIn = [NSString stringWithFormat:@"%@events/easysignin/%@",BASE_URL, [self getToken]];
    NSDictionary * dic = @{@"signin":strrr, @"content":event.eventItem.aimInfo?event.eventItem.aimInfo:@""};
    [[AFHTTPRequestOperationManager manager] POST:easySignIn parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (mapfileData) {
            [formData appendPartWithFileData:mapfileData
                                        name:@"mapfile"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"mapfile"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
        if (leftimageData) {
            [formData appendPartWithFileData:leftimageData
                                        name:@"leftimage"
                                    fileName:@"image2.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"leftimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
        if (rightimageData) {
            [formData appendPartWithFileData:rightimageData
                                        name:@"rightimage"
                                    fileName:@"image3.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"rightimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        EventModel *event = [[EventModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *eventDic =responseObject[@"resultData"];
            if (eventDic) {
                [event fromDictionary:eventDic];
            }
        }
        CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
        if (!tempCDEvent) {
            [CDEventDAO save:event];
        }
        else
        {
            [CDEventDAO update:event];
        }
        [CommonHelper postNotification:SIGN_IN_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":event}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:SIGN_IN_NOTIFICATION userInfo:nil];
    }];
}

-(void)easySignOut:(EventModel *)event mapfileData:(NSData *)mapfileData leftimageData:(NSData *)leftimageData rightimageData:(NSData *)rightimageData
{
    NSString * easySignOut = [NSString stringWithFormat:@"%@events/easysignout/%@/%@",BASE_URL, event.eventId,[self getToken]];
    
    NSDictionary *location = @{@"lo":[NSString stringWithFormat:@"%f", event.signOut.longitude], @"la":[NSString stringWithFormat:@"%f", event.signOut.latitude], @"lc":event.signOut.location?event.signOut.location:@""};

    NSData *da = [NSJSONSerialization dataWithJSONObject:location options:NSJSONWritingPrettyPrinted error:Nil];
    NSString *strrr = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    
    NSDictionary * dic = @{@"signout":strrr, @"content":event.eventItem.resultInfo,@"name":event.eventName?event.eventName:@""};

    [[AFHTTPRequestOperationManager manager] POST:easySignOut parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (mapfileData) {
            [formData appendPartWithFileData:mapfileData
                                        name:@"mapfile"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"mapfile"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
        if (leftimageData) {
            [formData appendPartWithFileData:leftimageData
                                        name:@"leftimage"
                                    fileName:@"image2.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"leftimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
        if (rightimageData) {
            [formData appendPartWithFileData:rightimageData
                                        name:@"rightimage"
                                    fileName:@"image3.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"rightimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        EventModel *event = [[EventModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *eventDic =responseObject[@"resultData"];
            if (eventDic) {
                [event fromDictionary:eventDic];
            }
        }
        CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
        if (!tempCDEvent) {
            [CDEventDAO save:event];
        }
        else
        {
            [CDEventDAO update:event];
        }
        [CommonHelper postNotification:SIGN_OUT_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":event}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:SIGN_OUT_NOTIFICATION userInfo:nil];
    }];
}


- (void)remarkPictureWithEvent:(EventModel *)event leftImageDate:(NSData *)leftImageData rightImageData:(NSData *)rightImageData
{
    NSString * remarkPictureURL = [NSString stringWithFormat:@"%@events/remark/%@/%@",BASE_URL, event.eventId,[self getToken]];
    
    NSDictionary * dic = @{@"content":event.remark};
    
    [[AFHTTPRequestOperationManager manager] POST:remarkPictureURL parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (leftImageData) {
            [formData appendPartWithFileData:leftImageData
                                        name:@"leftimage"
                                    fileName:@"image2.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"leftimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
        if (rightImageData) {
            [formData appendPartWithFileData:rightImageData
                                        name:@"rightimage"
                                    fileName:@"image3.jpg"
                                    mimeType:@"image/jpeg"];
        }else {
            [formData appendPartWithFileData:[[NSData alloc]init]
                                        name:@"rightimage"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        NSString *resultDescription = responseObject[@"resultDescription"];
        EventModel *event = [[EventModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *eventDic =responseObject[@"resultData"];
            if (eventDic) {
                [event fromDictionary:eventDic];
            }
        }
        CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
        if (!tempCDEvent) {
            [CDEventDAO save:event];
        }
        else
        {
            [CDEventDAO update:event];
        }
        [CommonHelper postNotification:REMARKPICTURE_NOTIFICATION userInfo:@{@"resultCode":resultCode, @"resultDescription":resultDescription, @"resultData":event}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:REMARKPICTURE_NOTIFICATION userInfo:nil];
    }];
}

- (void)verifyHasAttendanceSignIn
{
    NSString *checkURL = [NSString stringWithFormat:@"%@events/issignin/%@/%@",BASE_URL,[self getOwnId],[self getToken]];
    [[AFHTTPRequestOperationManager manager] GET:checkURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [CommonHelper postNotification:VERIFY_ATTENDANCE_SIGN_IN_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:VERIFY_ATTENDANCE_SIGN_IN_NOTIFICATION userInfo:nil];
    }];
}

- (void)signInRequestWithEventModel:(EventModel *)event mapfileData:(NSData *)mapfileData
{
    NSString *signInURL = [NSString stringWithFormat:@"%@events/signin/%@",BASE_URL,[self getToken]];
    NSDictionary *type = @{@"ud":@"1",@"na":@"考勤签到"};
    NSDictionary *location = @{@"lo":[NSString stringWithFormat:@"%f",event.signIn.longitude],@"la":[NSString stringWithFormat:@"%f",event.signIn.latitude],@"lc":event.signIn.location?event.signIn.location:@""};
    NSDictionary *public = @{@"ud":[self getOwnId],@"na":[self getCurrentUser].username};
    NSDictionary *postData = @{@"ty":type,@"pu":public,@"ow":public,@"si":location,@"cr":[self getCurrentUser].username,@"va":event.validSign};
    NSData *da = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:Nil];
    NSString *strrr = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    
    NSDictionary *MessageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%@",strrr],@"signin",
                                 nil];
    [[AFHTTPRequestOperationManager manager] POST:signInURL parameters:MessageDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (mapfileData) {
            [formData appendPartWithFileData:mapfileData
                                        name:@"file"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        EventModel *event = [[EventModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *eventDic =responseObject[@"resultData"];
            if (eventDic) {
                [event fromDictionary:eventDic];
            }
        }
        CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
        if (!tempCDEvent) {
            [CDEventDAO save:event];
        }
        else
        {
            [CDEventDAO update:event];
        }
        [CommonHelper postNotification:ATTENDANCE_SIGN_IN_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:ATTENDANCE_SIGN_IN_NOTIFICATION userInfo:nil];
    }];
}

- (void)signOutRequestWithEventModel:(EventModel *)event mapfileData:(NSData *)mapfileData
{
    NSString *signOutURL = [NSString stringWithFormat:@"%@events/signout/%@/%@",BASE_URL,event.eventId,[self getToken]];
    NSDictionary *location = @{@"lo":[NSString stringWithFormat:@"%f",event.signOut.longitude],@"la":[NSString stringWithFormat:@"%f",event.signOut.latitude],@"lc":event.signOut.location?event.signOut.location:@""};
    NSData *da = [NSJSONSerialization dataWithJSONObject:location options:NSJSONWritingPrettyPrinted error:Nil];
    NSString *strrr = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    NSDictionary *MessageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%@",strrr],@"signout",
                                 nil];
    [[AFHTTPRequestOperationManager manager] POST:signOutURL parameters:MessageDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (mapfileData) {
            [formData appendPartWithFileData:mapfileData
                                        name:@"file"
                                    fileName:@"image1.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resultCode = responseObject[@"resultCode"];
        EventModel *event = [[EventModel alloc]init];
        if (resultCode && [resultCode hasPrefix:@"I"]) {
            NSDictionary *eventDic =responseObject[@"resultData"];
            if (eventDic) {
                [event fromDictionary:eventDic];
            }
        }
        CDEvent *tempCDEvent = [CDEventDAO findById:event.eventId];
        if (!tempCDEvent) {
            [CDEventDAO save:event];
        }
        else
        {
            [CDEventDAO update:event];
        }
        [CommonHelper postNotification:ATTENDANCE_SIGN_OUT_NOTIFICATION userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper postNotification:ATTENDANCE_SIGN_OUT_NOTIFICATION userInfo:nil];
    }];
}
#pragma mark -
#pragma mark helper
-(void)saveImage:(UIImage *)image filename:(NSString *)filename
{
    [[SDImageCache sharedImageCache] storeImage:image forKey:filename toDisk:YES];
}


-(UIImage *)getImage:(NSString *)filename
{
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:filename];
}

-(NSURL *)getDownloadImageUrl:(NSString *)filename
{
    NSString * downloadImagePath = [NSString stringWithFormat:@"%@events/file/%@",BASE_URL, filename];
    return [NSURL URLWithString:downloadImagePath];
}
@end