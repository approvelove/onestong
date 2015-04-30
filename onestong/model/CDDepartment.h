//
//  CDDepartment.h
//  onestong
//
//  Created by 李健 on 14-7-4.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDDepartment : NSManagedObject

@property (nonatomic, retain) NSString * deptId;
@property (nonatomic, retain) NSString * deptname;
@property (nonatomic, retain) NSString * owneremail;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * parentName;
@property (nonatomic, retain) NSString * valid;
-(CDDepartment *)fromDictionary: (NSDictionary *)obj;
@end
