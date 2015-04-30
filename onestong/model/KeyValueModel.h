//
//  KeyValueModel.h
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyValueModel : NSObject<NSCoding>
@property(nonatomic, copy)NSString * modelId;
@property(nonatomic, copy)NSString * modelName;
-(KeyValueModel *)fromDictionary: (NSDictionary *)obj;
@end
