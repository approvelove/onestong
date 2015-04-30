//
//  KeyValueModel.m
//  onestong
//
//  Created by 王亮 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "KeyValueModel.h"

@implementation KeyValueModel
@synthesize modelId,modelName;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.modelId forKey:@"modelId"];
    [aCoder encodeObject:self.modelName forKey:@"modelName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.modelName = [aDecoder decodeObjectForKey:@"modelName"];
    }
    return self;
}

-(KeyValueModel *)fromDictionary: (NSDictionary *)obj
{
    if (obj[@"ud"]) {
        self.modelId = obj[@"ud"];
    }
    if (obj[@"na"]) {
        self.modelName = obj[@"na"];
    }
    return self;
}
@end
