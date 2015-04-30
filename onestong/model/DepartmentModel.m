//
//  DepartmentModel.m
//  onestong
//
//  Created by 王亮 on 14-4-28.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "DepartmentModel.h"

@implementation DepartmentModel
@synthesize departmentId, departmentName, departmentOwner, parentId,parentName;
-(DepartmentModel *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"id"]) {
        self.departmentId = obj[@"id"];
    }
    if (obj[@"na"]) {
        self.departmentName = obj[@"na"];
    }
    if (obj[@"ow"]) {
        self.departmentOwner = obj[@"ow"];
    }
    if (obj[@"pa"]) {
        self.parentId = obj[@"pa"];
    }
    if (obj[@"pn"]) {
        self.parentName = obj[@"pn"];
    }
    return self;
}
@end
