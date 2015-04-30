//
//  CDDepartment.m
//  onestong
//
//  Created by 李健 on 14-7-4.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "CDDepartment.h"


@implementation CDDepartment

@dynamic deptId;
@dynamic deptname;
@dynamic owneremail;
@dynamic parentId;
@dynamic parentName;
@dynamic valid;
-(CDDepartment *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"id"]) {
        self.deptId = obj[@"id"];
    }
    if (obj[@"na"]) {
        self.deptname = obj[@"na"];
    }
    if (obj[@"ow"]) {
        self.owneremail = obj[@"ow"];
    }
    if (obj[@"pa"]) {
        self.parentId = obj[@"pa"];
    }
    if (obj[@"va"]) {
        self.valid = obj[@"va"];
    }
    if (obj[@"pn"]) {
        self.parentName = obj[@"pn"];
    }
    return self;
}
@end
