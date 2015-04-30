//
//  SignDetailCell.m
//  onestong
//
//  Created by 李健 on 14-4-24.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "SignDetailCell.h"
#import "EventModel.h"
#import "TimeHelper.h"
#import "EventsService.h"
#import "UIImageView+WebCache.h"
#import "OSTImageView.h"
#import "GraphicHelper.h"
#import "CDUser.h"
#import "CDUserDAO.h"
#import "UsersModel.h"

#define MAX_TEXTHEIGHT 5000

@interface SignDetailCell()
{
    __weak IBOutlet UIView *signContentView;
    __weak IBOutlet OSTImageView *signInImageView_one;
    __weak IBOutlet OSTImageView *signInImageView_two;
    __weak IBOutlet OSTImageView *signOutImageView_one;
    __weak IBOutlet OSTImageView *signOutImageView_two;
    __weak IBOutlet OSTImageView *remarkImageView_one;
    __weak IBOutlet OSTImageView *remarkImageView_two;
    __weak IBOutlet OSTButton *iPhoneCallBtn;
    __weak IBOutlet OSTButton *iMessageCallBtn;
    
    __weak IBOutlet UILabel *eventTypeName;
    __weak IBOutlet UILabel *signIn_hm;
    __weak IBOutlet UILabel *signOut_hm;
    __weak IBOutlet UILabel *signIn_ymd;
    __weak IBOutlet UILabel *signOut_ymd;
    
    __weak IBOutlet UILabel *eventTitleLabel;
    
    __weak IBOutlet UILabel *signIn_description;
    __weak IBOutlet UILabel *signOut_description;
    __weak IBOutlet UILabel *remark_description;
    
    __weak IBOutlet UIView *bottomView;
    
    __weak IBOutlet NSLayoutConstraint *remarkLabelHeight;
    __weak IBOutlet NSLayoutConstraint *signInLabelHeight;
    __weak IBOutlet NSLayoutConstraint *signOutLabelHeight;
    __weak IBOutlet NSLayoutConstraint *bottomViewHeight;
    __weak IBOutlet NSLayoutConstraint *signInImageViewOne_Height;
    __weak IBOutlet NSLayoutConstraint *signInImageViewTwo_Height;
    __weak IBOutlet NSLayoutConstraint *signOutImageViewOne_Height;
    __weak IBOutlet NSLayoutConstraint *signOutImageViewTwo_Height;
    __weak IBOutlet NSLayoutConstraint *remarkImageViewOne_Height;
    __weak IBOutlet NSLayoutConstraint *remarkImageViewTwo_Height;
    __weak IBOutlet NSLayoutConstraint *eventTitleLabelHeight;
    __weak IBOutlet NSLayoutConstraint *signInImageViewTop;
    __weak IBOutlet NSLayoutConstraint *signOutImageViewTop;
    __weak IBOutlet NSLayoutConstraint *remarkImageViewTop;
    
    __weak IBOutlet NSLayoutConstraint *signInDescriptionLabelTop;
    __weak IBOutlet NSLayoutConstraint *signOutDescriptionLabelTop;
    __weak IBOutlet NSLayoutConstraint *remarkDescriptionLabelTop;
}
@end

@implementation SignDetailCell
@synthesize mapImageView,signOutButton,ostContentView = signContentView,editButton,writeSummaryButton;

- (void)awakeFromNib
{
    // Initialization code
    signContentView.layer.cornerRadius = 5.f;
}


#pragma mark -
#pragma mark 初始化操作

- (void)initPhoneAndMessageBtnWithModel:(EventModel *)eventModel
{
    CDUser *currentUser = [[[CDUserDAO alloc] init] findById:eventModel.publisher.modelId];
    iPhoneCallBtn.btnId = currentUser.phone;
    iMessageCallBtn.btnId = currentUser.phone;
    UsersModel *owner = [[[EventsService alloc] init] getCurrentUser];
    if ([owner.userId isEqualToString:currentUser.userId]) {
        iPhoneCallBtn.hidden = YES;
        iMessageCallBtn.hidden = YES;
    }
}

- (void)initAttendanceNoSignOutCellWithEventModel:(EventModel *)eventModel
{
    self.mapImageView.mapInfoAry = [NSArray array];
    [self.mapImageView registTapGestureShowImage];
    [self setSignInDate:[TimeHelper convertTimeToDateComponents:eventModel.signIn.createTime]];
    [self signInDescription:eventModel.eventItem.aimInfo];
    [self setEventTitleDescriptionWithString:eventModel.creator];
    [self initPhoneAndMessageBtnWithModel:eventModel];
    [GraphicHelper convertRectangleToEllipses:mapImageView withBorderColor:rgbaColor(255, 255, 255, 1.f) andBorderWidth:3.f andRadius:0.f];
    [GraphicHelper convertRectangleToEllipses:self.signOutButton withBorderColor:rgbaColor(255, 255, 255, 1.f) andBorderWidth:0.f andRadius:5.f];
}

- (void)initAttendanceHasSignOutCellWithEventModel:(EventModel *)eventModel
{
    [self initAttendanceNoSignOutCellWithEventModel:eventModel];
    [self setSignOutDate:[TimeHelper convertTimeToDateComponents:eventModel.signOut.createTime]];
    [self signOutDescription:eventModel.eventItem.resultInfo];
}

- (void)initVisitHasSignOutCellWithEventModel:(EventModel *)eventModel
{
    [signOutImageView_one registTapGestureShowImage];
    [signOutImageView_two registTapGestureShowImage];
    signOutImageView_one.imageSetted = YES;
    signOutImageView_two.imageSetted = YES;
    [self initVisitnoSignOutCellWithEventModel:eventModel];
    [self setSignOutImageViewWithImageURLArray:eventModel.eventItem.resultResource];
    [self setSignOutDate:[TimeHelper convertTimeToDateComponents:eventModel.signOut.createTime]];
    [self signOutDescription:eventModel.eventItem.resultInfo];
}

- (void)initVisitnoSignOutCellWithEventModel:(EventModel *)eventModel
{
    self.mapImageView.mapInfoAry = [NSArray array];
    [signInImageView_one registTapGestureShowImage];
    [signInImageView_two registTapGestureShowImage];
    [remarkImageView_one registTapGestureShowImage];
    [remarkImageView_two registTapGestureShowImage];

    [self.mapImageView registTapGestureShowImage];
    signInImageView_one.imageSetted = YES;
    signInImageView_two.imageSetted = YES;
    remarkImageView_one.imageSetted = YES;
    remarkImageView_two.imageSetted = YES;
    
    [GraphicHelper convertRectangleToEllipses:mapImageView withBorderColor:rgbaColor(255, 255, 255, 1.f) andBorderWidth:3.f andRadius:0.f];
    [GraphicHelper convertRectangleToEllipses:self.signOutButton withBorderColor:rgbaColor(255, 255, 255, 1.f) andBorderWidth:0.f andRadius:5.f];
    [GraphicHelper convertRectangleToEllipses:self.writeSummaryButton withBorderColor:rgbaColor(255, 255, 255, 1.f) andBorderWidth:0.f andRadius:5.f];
    
    [self initPhoneAndMessageBtnWithModel:eventModel];
    [self setEventTypeNameWithString:[self getAttributeStringWithMainString:eventModel.eventType.modelName subString:eventModel.publisher.modelName]];
    [self setSignInImageViewWithImageURLArray:eventModel.eventItem.aimResource];
    [self setRemarkImageViewWithImageURLArray:eventModel.remarkModel.imageSource];
    [self setSignInDate:[TimeHelper convertTimeToDateComponents:eventModel.signIn.createTime]];
    [self setEventTitleDescriptionWithString:eventModel.eventName];
    [self signInDescription:eventModel.eventItem.aimInfo];
    [self remarkDescription:eventModel.remark];
}

#pragma mark - 事件处理
- (IBAction)phoneCall:(OSTButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",sender.btnId]]];
}

- (IBAction)messageSend:(OSTButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",sender.btnId]]];
}

#pragma mark -
#pragma mark - 界面处理

- (NSMutableAttributedString *)getAttributeStringWithMainString:(NSString *)mainStr subString:(NSString *)subString
{
    NSString *titleStr = [NSString stringWithFormat:@"%@(%@)",mainStr,subString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    NSRange nameRange = [titleStr rangeOfString:[NSString stringWithFormat:@"(%@)",subString]];
    NSDictionary *nameAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13.f]};
    [attributedStr setAttributes:nameAttributes range:nameRange];
    return attributedStr;
}

- (void)setEventTypeNameWithString:(NSAttributedString *)name
{
    eventTypeName.attributedText = name;
}

- (void)setEventTitleDescriptionWithString:(NSString *)desStr
{
    eventTitleLabel.text = desStr;
    if (desStr.length>0) {
        CGRect rect = [self autoSizingLabelWithString:desStr andFont:20.f limitWidth:174.f];
        eventTitleLabelHeight.constant = rect.size.height;
    }
}

- (void)remarkDescription:(NSString *)descriptionStr
{
    //去掉字符串左右两边的空格
    descriptionStr = [descriptionStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    remark_description.text = descriptionStr;
    if (descriptionStr.length==0) {
        //当没有签到内容时
        remarkLabelHeight.constant = 0;
        remarkDescriptionLabelTop.constant = 10;
        return;
    }else{
        self.writeSummaryButton.hidden = YES;
        CGRect rect = [self autoSizingLabelWithString:descriptionStr andFont:15.f limitWidth:259.f];
        remarkLabelHeight.constant = rect.size.height;
    }
}

- (void)setRemarkImageViewWithImageURLArray:(NSArray *)imageArray
{
    if (imageArray && imageArray.count == 1) {
        self.writeSummaryButton.hidden = YES;
        NSString *filename = imageArray[0];
        [self setImageToImageView:remarkImageView_one withFilename:filename];
    }
    else if (imageArray && imageArray.count == 2) {
        self.writeSummaryButton.hidden = YES;
        NSString *filename0 = imageArray[0];
        NSString *filename1 = imageArray[1];
        [self setImageToImageView:remarkImageView_one withFilename:filename0];
        [self setImageToImageView:remarkImageView_two withFilename:filename1];
        
    }else{
        remarkImageViewOne_Height.constant = 0;
        remarkImageViewTwo_Height.constant = 0;
    }
}

- (void)setSignInImageViewWithImageURLArray:(NSArray *)imageArray
{
    if (imageArray && imageArray.count == 1) {
        NSString *filename = imageArray[0];
        [self setImageToImageView:signInImageView_one withFilename:filename];
    }
    else if (imageArray && imageArray.count == 2) {
        NSString *filename0 = imageArray[0];
        NSString *filename1 = imageArray[1];
        [self setImageToImageView:signInImageView_one withFilename:filename0];
        [self setImageToImageView:signInImageView_two withFilename:filename1];
    }else{
        signInImageViewOne_Height.constant = 0;
        signInImageViewTwo_Height.constant = 0;
        signInImageViewTop.constant = 0;
    }
}


- (void)setSignOutImageViewWithImageURLArray:(NSArray *)imageArray
{
    if (imageArray && imageArray.count == 1) {
        NSString *filename = imageArray[0];
        [self setImageToImageView:signOutImageView_one withFilename:filename];
    }
    else if (imageArray && imageArray.count == 2) {
        NSString *filename0 = imageArray[0];
        NSString *filename1 = imageArray[1];
        [self setImageToImageView:signOutImageView_one withFilename:filename0];
        [self setImageToImageView:signOutImageView_two withFilename:filename1];
    }else{
        signOutImageViewOne_Height.constant = 0;
        signOutImageViewTwo_Height.constant = 0;
        signOutImageViewTop.constant = 0;
    }
}

-(void)setImageToImageView:(UIImageView *)imageView withFilename:(NSString *)filename
{
    EventsService *eventService = [[EventsService alloc]init];
    UIImage *fileimage = [eventService getImage:filename];
    NSURL * url = [eventService getDownloadImageUrl:filename];
    
    NSData *imgData = [self readFileFromImgDocumentsWithFileName:filename];
    if (imgData) {
        [imageView setImage:[UIImage imageWithData:imgData]];
        return;
    }
    
    if (fileimage) {
        [imageView setImage:fileimage];
    }else{
        [imageView setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [eventService saveImage:image filename:filename];
            [self storeImageToDocumentWithData:UIImageJPEGRepresentation(image, 1.f) andName:filename];
        }];
    }
}

- (void)setSignInDate:(NSDateComponents *)dateCompnents
{
    if (dateCompnents.year == 1970) {
        return;
    }
    signIn_hm.text = [NSString stringWithFormat:@"%@:%@",[self timeFormatWithNum:dateCompnents.hour],[self timeFormatWithNum:dateCompnents.minute]];
    signIn_ymd.text = [NSString stringWithFormat:@"%ld年%02ld月%ld日",(long)dateCompnents.year,(long)dateCompnents.month,(long)dateCompnents.day];
}

- (void)setSignOutDate:(NSDateComponents *)dateCompnents
{
    if (dateCompnents.year == 1970) {
        return;
    }
    signOut_hm.text = [NSString stringWithFormat:@"%@:%@",[self timeFormatWithNum:dateCompnents.hour],[self timeFormatWithNum:dateCompnents.minute]];
    signOut_ymd.text = [NSString stringWithFormat:@"%ld年%02ld月%ld日",(long)dateCompnents.year,(long)dateCompnents.month,(long)dateCompnents.day];
}


- (void)signInDescription:(NSString *)descriptionStr
{
    //去掉字符串左右两边的空格
    descriptionStr = [descriptionStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descriptionStr.length==0) {
        signInLabelHeight.constant = 0;
        signInImageViewTop.constant = 0;
//        signInDescriptionLabelTop.constant = 0;
        //当没有签到内容时
    }else{
        CGRect rect = [self autoSizingLabelWithString:descriptionStr andFont:14.6f limitWidth:259.f];
        signIn_description.text = descriptionStr;
        signInLabelHeight.constant = rect.size.height;
    }
}
    
- (void)signOutDescription:(NSString *)descriptionStr
{
    descriptionStr = [descriptionStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descriptionStr.length==0) {
        //当没有签到内容时
        signOutLabelHeight.constant = 0;
        signOutDescriptionLabelTop.constant = 0;
    }else{
        CGRect rect = [self autoSizingLabelWithString:descriptionStr andFont:14.6f limitWidth:259.f];
        signOutLabelHeight.constant = rect.size.height+5;
        signOut_description.text = descriptionStr;
        signOut_description.numberOfLines = 0;
        signOut_description.lineBreakMode = NSLineBreakByWordWrapping;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (SignDetailCell *)loadVisitEventNoSignOutFromNib
{
    SignDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SignDetailCell" owner:self options:nil] objectAtIndex:0];
    return cell;
}

+ (SignDetailCell *)loadVisitEventHasSignOutFromNib
{
    SignDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SignDetailCell" owner:self options:nil] objectAtIndex:1];
    return cell;
}

+ (SignDetailCell *)loadAttendanceEventNoSignOutFromNib
{
    SignDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SignDetailCell" owner:self options:nil] objectAtIndex:2];
    return cell;
}

+ (SignDetailCell *)loadAttendanceEventHasSignOutFromNib
{
    SignDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SignDetailCell" owner:self options:nil] objectAtIndex:3];
    return cell;
}

///////helper
- (CGRect)autoSizingLabelWithString:(NSString *)tempString andFont:(float)afont limitWidth:(float)aWidth
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 0, 0)];
    [titleLabel setNumberOfLines:0];
    titleLabel.text =tempString;
    
    UIFont *font =[UIFont fontWithName:@"Arial" size:afont];
    CGSize size =CGSizeMake(aWidth, MAX_TEXTHEIGHT);
    titleLabel.font=font;
    
    CGSize lableSize = [tempString drawInRect:CGRectMake(0, 0, size.width, size.height) withFont:font lineBreakMode:NSLineBreakByCharWrapping];
    [titleLabel setFrame:CGRectMake(15, 3, lableSize.width+5, lableSize.height)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    return titleLabel.frame;
}

#pragma mark -
#pragma mark helper method
- (NSData *)readFileFromImgDocumentsWithFileName:(NSString *)fileName
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self imageFilePath],fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

- (void)storeImageToDocumentWithData:(NSData *)data andName:(NSString *)fileName
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self imageFilePath],fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return;
    }
    [data writeToFile:filePath atomically:YES];
}

- (NSString *)imageFilePath
{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[array objectAtIndex:0] stringByAppendingPathComponent:@"/img"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        return fileName;
    }
   BOOL isSuc = [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuc) {
        NSLog(@"success");
    }
    return fileName;
}

- (NSString *)stringAppendingString:(NSString *)str withString:(NSString *) appendStr
{
    if (appendStr.length == 0 || appendStr == nil) {
        return str;
    }
    else
    {
        if (str.length == 0 || str == nil) {
            return appendStr;
        }
        else
        {
            NSString *newStr = [NSString stringWithFormat:@"%@\n%@",str,appendStr];
            return newStr;
        }
    }
}

//格式化时间
- (NSString *)timeFormatWithNum:(NSInteger)num
{
    NSString *str = nil;
    if (num<10) {
        str = [NSString stringWithFormat:@"0%ld",(long)num];
    }
    else
    {
        str = [NSString stringWithFormat:@"%ld",(long)num];
    }
    return str;
}
@end
