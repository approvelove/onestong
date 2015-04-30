//
//  RemarkModel.m
//  onestong
//
//  Created by 李健 on 14-5-7.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "remarkModel.h"

@implementation RemarkModel
@synthesize imageSource;

- (RemarkModel *)fromArray:(NSArray *)obj
{
    if (obj) {
        NSMutableArray *img_ary = [NSMutableArray array];
        for (int i = 0; i<[obj count]; i++) {
            [img_ary addObject:obj[i][@"ur"]];
        }
        self.imageSource = img_ary;
    }
    return self;
}

@end
