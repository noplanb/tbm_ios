//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import "TBMFeatureUnlockDialogView.h"
#import "HexColors.h"
#import "TBMFeatureUnlockModulePresenter.h"

NSString *const kTBMFeatureUnlockDialogHeaderFontName = @"AppleSDGothicNeo-Regular";
NSString *const kTBMFeatureUnlockDialogSubHeaderFontName = @"HelveticaNeue-LightItalic";
NSString *const kTBMFeatureUnlockDialogFeatureFontName = @"HelveticaNeue";
NSString *const kTBMFeatureUnlockDialogButtonFontName = @"HelveticaNeue-Bold";

@interface TBMFeatureUnlockDialogView ()

//Subviews
@property(nonatomic, strong) UIView *dialogView;
@property(nonatomic, strong) UIImageView *starsImage;
@property(nonatomic, strong) UILabel *headerLabel;
@property(nonatomic, strong) UILabel *subHeaderLabel;
@property(nonatomic, strong) UILabel *featureNameLabel;
@property(nonatomic, strong) UIView *showMeButton;
@property(nonatomic, strong) UIView *showMeButtonRoundedRectangle;
@property(nonatomic, strong) UIView *showMeButtonSquare;
@property(nonatomic, strong) UILabel *showMeButtonLabel;
@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;
@end

@implementation TBMFeatureUnlockDialogView

#pragma mark - Interface

- (void)showInGrid:(id <TBMGridModuleInterface>)gridModule
{
    UIView *view = gridModule.viewForDialog;
    self.gridModule = gridModule;
    self.frame = view.bounds;
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [self showAnimated];
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65f];
    self.hidden = YES;
    self.alpha = 0;
    self.userInteractionEnabled = YES;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutDialogView];
    [self layoutStarsImage];
    [self layoutHeader];
    [self layoutSubHeader];
    [self layoutFeatureName];
    [self layoutButton];
}

- (void)layoutDialogView
{
    CGFloat horizMargin = 25.f;
    CGFloat height = CGRectGetHeight(self.bounds) / 2.f;
    CGFloat vertMargin = (CGRectGetHeight(self.bounds) - height) / 2;
    self.dialogView.frame = CGRectMake(
            CGRectGetMinX(self.bounds) + horizMargin,
            CGRectGetMinY(self.bounds) + vertMargin,
            CGRectGetWidth(self.bounds) - (2.f * horizMargin),
            height
    );
}

- (void)layoutStarsImage
{
    CGFloat imageRatio = self.starsImage.image.size.height / self.starsImage.image.size.width;
    CGFloat imageWidth = CGRectGetWidth(self.dialogView.bounds) / 2;
    CGFloat imageHeight = imageWidth * imageRatio;
    CGFloat horizMargin = (CGRectGetWidth(self.dialogView.bounds) - CGRectGetWidth(self.starsImage.frame)) / 2;
    CGFloat vertMargin = imageHeight / 2;
    self.starsImage.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds) + horizMargin,
            CGRectGetMinY(self.dialogView.bounds) - vertMargin,
            imageWidth,
            imageHeight
    );


}

- (void)layoutHeader
{
    CGFloat vertMargin = 75.f;

    self.headerLabel.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds),
            CGRectGetMinY(self.dialogView.bounds) + vertMargin,
            CGRectGetWidth(self.dialogView.bounds),
            30.f
    );
}

- (void)layoutSubHeader
{
    CGFloat vertMargin = 25.f;
    self.subHeaderLabel.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds),
            CGRectGetMaxY(self.headerLabel.frame) + vertMargin,
            CGRectGetWidth(self.dialogView.bounds),
            20.f
    );
}

- (void)layoutFeatureName
{
    CGFloat vertMargin = 25.f;
    self.featureNameLabel.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds),
            CGRectGetMaxY(self.subHeaderLabel.frame) + vertMargin,
            CGRectGetWidth(self.dialogView.bounds),
            20.f
    );
}

- (void)layoutButton
{
    CGFloat labelHeight = 30.f;
    CGFloat buttonHeight = 70.f;
    self.showMeButtonRoundedRectangle.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds),
            CGRectGetMaxY(self.dialogView.bounds) - buttonHeight,
            CGRectGetWidth(self.dialogView.bounds),
            buttonHeight
    );

    self.showMeButtonSquare.frame = CGRectMake(
            CGRectGetMinX(self.dialogView.bounds),
            CGRectGetMaxY(self.dialogView.bounds) - buttonHeight,
            CGRectGetWidth(self.dialogView.bounds),
            buttonHeight / 2
    );

    self.showMeButtonLabel.frame = CGRectMake(
            CGRectGetMinX(self.showMeButtonRoundedRectangle.frame),
            CGRectGetMinY(self.showMeButtonRoundedRectangle.frame) + (labelHeight / 2),
            CGRectGetWidth(self.showMeButtonRoundedRectangle.frame),
            labelHeight
    );

}

#pragma mark - Lazy initialization (subviews setup)

- (UIView *)dialogView
{
    if (!_dialogView)
    {
        _dialogView = [[UIView alloc] initWithFrame:CGRectZero];
        _dialogView.clipsToBounds = NO;
        _dialogView.layer.cornerRadius = 19.f;
        _dialogView.backgroundColor = [UIColor colorWithHexString:@"#1C1C19"];
        [self addSubview:_dialogView];
    }
    return _dialogView;
}

- (UIImageView *)starsImage
{
    if (!_starsImage)
    {
        _starsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"three-stars"]];
        [self.dialogView addSubview:_starsImage];
    }
    return _starsImage;
}

- (UILabel *)headerLabel
{
    if (!_headerLabel)
    {
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _headerLabel.font = [UIFont fontWithName:kTBMFeatureUnlockDialogHeaderFontName size:38];
        _headerLabel.textColor = [UIColor whiteColor];
        _headerLabel.text = @"Hurray,";
        _headerLabel.textColor = [UIColor whiteColor];
        _headerLabel.textAlignment = NSTextAlignmentCenter;
        _headerLabel.minimumScaleFactor = .7f;
        _headerLabel.numberOfLines = 0;
        [self.dialogView addSubview:_headerLabel];
    }
    return _headerLabel;
}

- (UILabel *)subHeaderLabel
{
    if (!_subHeaderLabel)
    {
        _subHeaderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subHeaderLabel.font = [UIFont fontWithName:kTBMFeatureUnlockDialogSubHeaderFontName size:18];
        _subHeaderLabel.textColor = [UIColor colorWithHexString:@"#A8A294"];
        _subHeaderLabel.text = @"You unlocked a new feature!";
        _subHeaderLabel.textAlignment = NSTextAlignmentCenter;
        _subHeaderLabel.minimumScaleFactor = .7f;
        _subHeaderLabel.numberOfLines = 0;
        [self.dialogView addSubview:_subHeaderLabel];
    }
    return _subHeaderLabel;
}

- (UILabel *)featureNameLabel
{
    if (!_featureNameLabel)
    {
        _featureNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _featureNameLabel.font = [UIFont fontWithName:kTBMFeatureUnlockDialogFeatureFontName size:16];
        _featureNameLabel.textColor = [UIColor colorWithHexString:@"#F68B1F"];
        _featureNameLabel.text = @"You unlocked a new feature!";
        _featureNameLabel.textAlignment = NSTextAlignmentCenter;
        _featureNameLabel.minimumScaleFactor = .7f;
        _featureNameLabel.numberOfLines = 0;
        [self.dialogView addSubview:_featureNameLabel];
    }
    return _featureNameLabel;
}

- (UIView *)showMeButtonRoundedRectangle
{
    if (!_showMeButtonRoundedRectangle)
    {
        _showMeButtonRoundedRectangle = [[UIView alloc] initWithFrame:CGRectZero];
        _showMeButtonRoundedRectangle.layer.cornerRadius = 18.f;
        _showMeButtonRoundedRectangle.backgroundColor = [UIColor blackColor];
        [self.dialogView addSubview:_showMeButtonRoundedRectangle];
    }
    return _showMeButtonRoundedRectangle;
}

- (UIView *)showMeButtonSquare
{
    if (!_showMeButtonSquare)
    {
        _showMeButtonSquare = [[UIView alloc] initWithFrame:CGRectZero];
        _showMeButtonSquare.backgroundColor = [UIColor blackColor];

        [self.dialogView addSubview:_showMeButtonSquare];
    }
    return _showMeButtonSquare;
}

- (UIView *)showMeButton
{
    if (!_showMeButton)
    {
        _showMeButton = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_showMeButton];
    }
    return _showMeButton;
}

- (UILabel *)showMeButtonLabel
{
    if (!_showMeButtonLabel)
    {
        _showMeButtonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _showMeButtonLabel.font = [UIFont fontWithName:kTBMFeatureUnlockDialogButtonFontName size:18];
        _showMeButtonLabel.textColor = [UIColor colorWithHexString:@"#A8A294"];
        _showMeButtonLabel.text = @"Show me!";
        _showMeButtonLabel.textAlignment = NSTextAlignmentCenter;
        _showMeButtonLabel.minimumScaleFactor = .7f;
        _showMeButtonLabel.numberOfLines = 0;
        [self.dialogView addSubview:_showMeButtonLabel];
    }

    return _showMeButtonLabel;
}


#pragma mark - Handle events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView *touchedView = [self hitTest:locationPoint withEvent:event];
    if ([touchedView isEqual:self.dialogView]
            || [touchedView isEqual:self.showMeButtonLabel]
            || [touchedView isEqual:self.showMeButtonRoundedRectangle]
            || [touchedView isEqual:self.showMeButtonSquare]
            )
    {
        [self buttonDidTap:self];
    } else
    {
        [self dimViewDidTap:self];
    }
}

- (void)buttonDidTap:(id)sender
{
    [self hide];
    [self.presenter showMeButtonDidPress];
}

- (void)dimViewDidTap:(id)sender
{
    [self dismiss];
}

- (void)setFeatureDescription:(NSString *)featureDescription
{
    if (_featureDescription != featureDescription)
    {
        _featureDescription = featureDescription;
        self.featureNameLabel.text = featureDescription;
    }
}

#pragma mark - Private

- (void)showAnimated
{
    self.hidden = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMinY(self.dialogView.frame);
    CGFloat correctDialogTop = CGRectGetMinY(self.dialogView.frame);
    CGFloat dialogTop = CGRectGetMinY(self.bounds) - height;

    self.dialogView.frame = [self makeDialogViewRectWithTop:dialogTop];
    [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {

        self.dialogView.frame = [self makeDialogViewRectWithTop:correctDialogTop];
        self.alpha = 1;
    }                completion:^(BOOL finished)
    {

    }];

}

- (CGRect)makeDialogViewRectWithTop:(CGFloat)top
{
    return CGRectMake(self.dialogView.frame.origin.x, top,
            CGRectGetWidth(self.dialogView.frame),
            CGRectGetHeight(self.dialogView.frame)
    );
}

- (void)dismiss
{
    [self hide];
    [self.presenter dialogDidDismiss];
}

- (void)hide
{
    [UIView animateWithDuration:.25f animations:^
    {
        self.alpha = 0;
    }];
    self.hidden = YES;
}

@end