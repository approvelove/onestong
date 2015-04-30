//
//  DepartmentModel.h
//  onestong
//
//  Created by 王亮 on 14-4-28.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartmentModel : NSObject
@property (copy, nonatomic) NSString *departmentId;//编号 id
@property (copy, nonatomic) NSString *departmentName;//设备编号 na
@property (copy, nonatomic) NSString *departmentOwner;//负责人邮箱地址 ow
@property (copy, nonatomic) NSString *parentId;//上级部门编号 pa
@property (copy, nonatomic) NSString *valid; //是否有效， 0:有效 1:无效
@property (copy, nonatomic) NSString *parentName; // name-name

-(DepartmentModel *)fromDictionary: (NSDictionary *)obj;
@end
