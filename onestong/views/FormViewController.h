//
//  FormViewController.h
//  onestong
//
//  Created by 李健 on 14-4-23.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "BaseViewController.h"

static const float KEYBOARD_HEIGHT = 216.f;

@interface FormViewController : BaseViewController<UITextFieldDelegate>


/**
 *	@brief	实现表单
 *
 *	@param 	scrollView 	要实现自动定位的对象
 *
 *	@return	nil
 */
- (void)registFormScrollView:(UIScrollView *)scrollView;

@end
