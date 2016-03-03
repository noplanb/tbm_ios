//
//  ZZGridCollectionCellPreviewView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewPreview.h"
#import "ZZGridUIConstants.h"
#import "ZZDateLabel.h"
#import "ZZGridCell.h"

typedef enum : NSUInteger {
    ZZDateFormatTemplateToday,
    ZZDateFormatTemplateWeek,
    ZZDateFormatTemplateYear,
} ZZDateFormatTemplateName;

static NSString *ZZDateFormatTemplate[] = {
    @"jjmm",    //ZZDateFormatTemplateToday
    @"Ejjmm",   //ZZDateFormatTemplateWeek
    @"MMMd"     //ZZDateFormatTemplateYear
};

static CGFloat const kThumbnailBorderWidth = 2;

@interface ZZGridStateViewPreview ()

@property (nonatomic, assign) BOOL isVideoPlaying;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ZZGridStateViewPreview


- (instancetype)initWithPresentedView:(ZZGridCell *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        [self thumbnailImageView];
        [self userNameLabel];
//        [self containFriendView];
        [self videoViewedView];
        [self dateLabel];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        [super updateWithModel:model];
        [self _setupThumbnailWithModel:model];
        self.userNameLabel.hidden = NO;
        [self _handleFailedVideoDownloadWithModel:model];
        [self _updateVideoSentDate:model.lastMessageDate];
    });
}

#pragma mark - Private

- (void)_updateVideoSentDate:(NSDate *)date
{
    self.dateLabel.text = [self _formattedDate:date];
}

- (NSString *)_formattedDate:(NSDate *)date
{
    if (ANIsEmpty(date))
    {
        return nil;
    }
    
    BOOL isToday = date.an_isToday;
    NSUInteger sevenDays = 7;
    
    NSString *template;
    
    if (isToday)
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateToday];
    }
    else if ([date an_daysBetweenDate:[NSDate date]] <= sevenDays)
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateWeek];
    }
    else
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateYear];
    }

    self.dateFormatter.dateFormat =
    [NSDateFormatter dateFormatFromTemplate:template
                                    options:0
                                     locale:[NSLocale currentLocale]];

    return [self.dateFormatter stringFromDate:date];

}

- (void)_handleFailedVideoDownloadWithModel:(ZZGridCellViewModel*)model
{
    if (model.badgeNumber == 0 && (model.state & ZZGridCellViewModelStateVideoFailedPermanently))
    {
        [self.presentedView hideActiveBorder];
    }
}

- (void)_setupThumbnailWithModel:(ZZGridCellViewModel*)model
{
    UIImage* thumbImage = [model videoThumbnailImage];
    
    if (!thumbImage)
    {
//        self.thumbnailImageView.contentMode = UIViewContentModeCenter;
//        self.thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridStatusViewThumbnailDefaultColor;
//        thumbImage = [model thumbnailPlaceholderImage];
    }
    else
    {
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        self.thumbnailImageView.image = thumbImage;
    }
    
}

- (void)_startVideo:(UITapGestureRecognizer *)recognizer
{
    if (!self.superview.isHidden && [self.model isEnablePlayingVideo])
    {
        [self hideAllAnimationViews];
        [self.presentedView hideActiveBorder];
//        self.userNameLabel.hidden = YES;
        [self.model updateVideoPlayingStateTo:YES];
    }
}


#pragma mark - Lazy Load

- (UIImageView*)thumbnailImageView
{
    if (!_thumbnailImageView)
    {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        _thumbnailImageView.userInteractionEnabled = YES;
        _thumbnailImageView.clipsToBounds = YES;
        UITapGestureRecognizer* tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_startVideo:)];
        [_thumbnailImageView addGestureRecognizer:tap];
        
        [self insertSubview:_thumbnailImageView belowSubview:self.backGradientView];
        
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
    }
    return _thumbnailImageView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel)
    {
        UILabel *label = [ZZDateLabel new];
        
        label.font = [UIFont zz_mediumFontWithSize:kLayoutConstDateLabelFontSize];
        label.text = @"";
        label.textColor = [ZZColorTheme shared].gridCellTextColor;
        
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(label.font.pointSize * 1.5));
        }];
        
        _dateLabel = label;
    }
    
    return _dateLabel;
}

@end
