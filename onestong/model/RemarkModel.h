//
//  RemarkModel.h
//  onestong
//
//  Created by 李健 on 14-5-7.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemarkModel : NSObject
@property(copy, nonatomic)NSArray *imageSource; //ur 图片资源

-(RemarkModel *)fromArray: (NSArray *)obj;

@end
