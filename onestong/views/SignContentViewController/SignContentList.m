//
//  SignContentList.m
//  onestong
//
//  Created by 李健 on 14-7-9.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SignContentList.h"
#import "GraphicHelper.h"

@interface SignContentList()<UITableViewDataSource,UITableViewDelegate>
{
    
}
@end

@implementation SignContentList
//@synthesize tableListView;
@synthesize dataSource,selectString,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [GraphicHelper convertRectangleToEllipses:self withBorderColor:[UIColor lightGrayColor] andBorderWidth:0.5 andRadius:3.f];
    if (self.dataSource) {
        return self.dataSource.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellone"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
//    cell.textLabel.textColor = [UIColor whiteColor];
    if ([cell.textLabel.text isEqualToString:self.selectString]) {
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:20.f];
    UIImageView *imageLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 39.5, self.frame.size.width-20, 0.5)];
    imageLine.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:imageLine];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellAry = [tableView visibleCells];
    [cellAry enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
        obj.textLabel.textColor = [UIColor blackColor];
    }];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor orangeColor];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(signContentListSelectedTitle:)]) {
        [self.delegate signContentListSelectedTitle:cell.textLabel.text];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (SignContentList *)loadFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"SignContentList" owner:nil options:nil] objectAtIndex:0];
}
@end
