//
//  EventItemModel.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "EventItemModel.h"

@implementation EventItemModel
@synthesize aimInfo,aimResource,resultInfo,resultResource,eventId;

-(EventItemModel *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"ar"]) {
        NSMutableArray *imgIn_ary = [NSMutableArray array];
        for (int i = 0; i<[obj[@"ar"] count]; i++) {
            [imgIn_ary addObject:[obj[@"ar"] objectAtIndex:i][@"ur"]];
        }
        self.aimResource = imgIn_ary;
    }
    
    if (obj[@"rr"]) {
        NSMutableArray *imgOut_ary = [NSMutableArray array];
        for (int i = 0; i<[obj[@"rr"] count]; i++) {
            [imgOut_ary addObject:[obj[@"rr"] objectAtIndex:i][@"ur"]];
        }
        self.resultResource = imgOut_ary;
    }
    
    if (obj[@"ai"]) {
        self.aimInfo = obj[@"ai"];
    }
    
    if (obj[@"ri"]) {
        self.resultInfo = obj[@"ri"];
    }
    return self;
}
@end
