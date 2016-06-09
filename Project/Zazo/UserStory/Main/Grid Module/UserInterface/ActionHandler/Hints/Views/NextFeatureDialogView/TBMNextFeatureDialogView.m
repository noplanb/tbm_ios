//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMNextFeatureDialogView.h"
#import "NSArray+ZZAdditions.h"

CGFloat const kDialogHeight = 50.f;
CGFloat const kHeaderHeight = 30.f;
CGFloat const kSubHeaderHeight = 25.f;
CGFloat const kIconSize = 50.f;
CGFloat const kElementsVerticalMargin = 15.f;
CGFloat const kElementsHorizontalMargin = 15.f;

static CGFloat const kNextFeatureDialogAnimationDelay = 6.0f;
static CGFloat const kNextFeatureAnimationDuration = 0.35f;

@interface TBMNextFeatureDialogView ()

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *subHeaderLabel;
@property (nonatomic, strong) UIImageView *presentIconImage;
@property (nonatomic, strong) NSDictionary *posibbleHeaders;
@property (nonatomic, copy) void (^completionBlock)();

@end

@implementation TBMNextFeatureDialogView


#pragma mark - Interface


+ (void)showNextFeatureDialogWithPresentedView:(UIView *)presentedView completionBlock:(void (^)())completionBlock
{
    TBMNextFeatureDialogView *nextFeatureView = [TBMNextFeatureDialogView new];
    nextFeatureView.completionBlock = completionBlock;
    [presentedView addSubview:nextFeatureView];
    [presentedView bringSubviewToFront:nextFeatureView];
    [nextFeatureView showAnimated];
}


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.65f];
        [self hide];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView *touchedView = [self hitTest:locationPoint withEvent:event];
    if ([touchedView isEqual:self])
    {
        [self dialogDidSelect:self];
    }
}

- (void)dialogDidSelect:(id)sender
{
    [self hide];
}

- (void)hide
{
    self.hidden = YES;
    self.alpha = 0;
    if (self.completionBlock)
    {
        self.completionBlock();
    }
}

#pragma mark - Layout

- (void)showAnimated
{
    [self setupRandomHeaders];
    self.hidden = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat correctDialogTop = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat dialogTop = - height;
    self.frame = [self makeRectWithTop:dialogTop];
    self.alpha = 1;

    [UIView animateWithDuration:kNextFeatureAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = [self makeRectWithTop:correctDialogTop];
            }        completion:^(BOOL finished) {
                [self hideAnimated];
            }];
}

- (void)setupRandomHeaders
{
    NSString *header = [self.posibbleHeaders.allKeys zz_randomObject];
    self.headerLabel.text = header;
    self.subHeaderLabel.text = self.posibbleHeaders[header];
}

- (void)hideAnimated
{
    CGFloat correctDialogTop = - self.frame.size.height;

    [UIView animateWithDuration:kNextFeatureAnimationDuration
                          delay:kNextFeatureDialogAnimationDelay
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = [self makeRectWithTop:correctDialogTop];
                self.alpha = 0;
            }
                     completion:^(BOOL finished) {
                         [self hide];
                     }];
}

- (CGRect)makeRectWithTop:(CGFloat)top
{
    return CGRectMake(self.frame.origin.x,
            top,
            CGRectGetWidth(self.frame),
            CGRectGetHeight(self.frame)
    );
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBaseView];
    [self layoutIconImage];
    [self layoutHeaderLabel];
    [self layoutSubHeaderLabel];
}

- (void)layoutIconImage
{
    self.presentIconImage.frame = CGRectMake(
            CGRectGetMinX(self.bounds) + kElementsHorizontalMargin,
            (CGRectGetHeight(self.bounds) / 2) - (kIconSize / 2),
            kIconSize,
            kIconSize
    );
}

- (void)layoutSubHeaderLabel
{
    self.subHeaderLabel.frame = CGRectMake(
            CGRectGetMinX(self.superview.bounds) + kIconSize + (kElementsHorizontalMargin * 2),
            CGRectGetMaxY(self.presentIconImage.frame) - kSubHeaderHeight,
            CGRectGetWidth(self.superview.bounds) - (kElementsHorizontalMargin * 3) - kIconSize,
            kSubHeaderHeight
    );
}

- (void)layoutBaseView
{
    CGRect superBounds = self.superview.bounds;
    self.frame = CGRectMake(CGRectGetMinX(superBounds), CGRectGetMaxY(superBounds) - kDialogHeight, CGRectGetWidth(superBounds), kDialogHeight);
}

- (void)layoutHeaderLabel
{

    CGRect bounds = self.bounds;
    CGRect iconFrame = self.presentIconImage.frame;
    self.headerLabel.frame = CGRectMake(
            CGRectGetMaxX(iconFrame) + kElementsHorizontalMargin,
            CGRectGetMinY(iconFrame),
            CGRectGetWidth(bounds) - (kElementsHorizontalMargin * 3) - kIconSize,
            kHeaderHeight
    );
}

#pragma mark - Lazy initialization

- (UILabel *)headerLabel
{
    if (!_headerLabel)
    {
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        _headerLabel.textColor = [UIColor whiteColor];
        _headerLabel.adjustsFontSizeToFitWidth = YES;
        _headerLabel.text = @"Unlock Another Feature";
        _headerLabel.textAlignment = NSTextAlignmentLeft;
        _headerLabel.minimumScaleFactor = .7f;
        _headerLabel.numberOfLines = 0;
        [self addSubview:_headerLabel];
    }
    return _headerLabel;
}

- (UILabel *)subHeaderLabel
{
    if (!_subHeaderLabel)
    {
        _subHeaderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        _subHeaderLabel.textColor = [UIColor an_colorWithHexString:@"#F68B1F"];
        _subHeaderLabel.text = @"Just Zazo Someone new!";
        _subHeaderLabel.adjustsFontSizeToFitWidth = YES;
        _subHeaderLabel.textAlignment = NSTextAlignmentLeft;
        _subHeaderLabel.minimumScaleFactor = .7f;
        _subHeaderLabel.numberOfLines = 0;
        [self addSubview:_subHeaderLabel];
    }
    return _subHeaderLabel;
}

- (UIImageView *)presentIconImage
{
    if (!_presentIconImage)
    {
        _presentIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"present-icon"]];
        _presentIconImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_presentIconImage];
    }
    return _presentIconImage;
}

- (NSDictionary *)posibbleHeaders
{
    if (!_posibbleHeaders)
    {
        _posibbleHeaders = @{@"What is in the box?" : @"Find out. Just Zazo someone new.",
                @"A gift is waiting!" : @"Find out. Just Zazo someone new.",
                @"Unlock an another feature!" : @"Just Zazo someone new.",
                @"Surprise feature waiting" : @"Zazo someone new to unlock.",
                @"Unlock a secret feature!" : @"Just Zazo someone new.",
                @"Unlock a surprise!" : @"Just Zazo someone new.",
                @"What did you win?" : @"Find out. Zazo someone new."};
    }
    return _posibbleHeaders;
}

- (void)dismiss
{
    [self hideAnimated];
}


@end