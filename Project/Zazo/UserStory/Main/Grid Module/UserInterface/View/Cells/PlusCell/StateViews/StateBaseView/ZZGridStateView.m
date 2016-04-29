//
//  ZZGridCollectionCellBaseView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView.h"
#import "ZZGridUIConstants.h"
#import "ZZGridCellGradientView.h"
#import "ZZLoadingAnimationView.h"
#import "ZZCellEffectView.h"
#import "ZZHoldIndicator.h"
#import "ZZNumberBadge.h"
#import "ZZSentBadge.h"

@interface ZZGridStateView ()

@property (nonatomic, assign) BOOL isSentBadgeShifted;

@end

@implementation ZZGridStateView

- (instancetype)initWithPresentedView:(ZZGridCell*)presentedView
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor1;
        self.presentedView = presentedView;
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;

        // upload video animation
        if (self.model.state & ZZGridCellViewModelStateVideoWasUploaded)
        {
            [self updateSendBadgePosition];
            self.sentBadge.hidden = NO;
        }

        model.playerContainerView = self;

        model.usernameLabel = self.userNameLabel;
        [self.model reloadDebugVideoStatus];

        self.sentBadge.state =  model.state & ZZGridCellViewModelStateVideoWasViewed ? ZZSentBadgeStateViewed : ZZSentBadgeStateSent;

        [self _setupDownloadAnimationsWithModel:model];
    });
}


#pragma mark - Downloaded Animation behavior

- (void)_setupDownloadAnimationsWithModel:(ZZGridCellViewModel*)model
{
    
    if (self.model.state & ZZGridCellViewModelStateVideoFirstVideoDownloading)
    {
        [self _setupDownloadedStateWithModel:model];
    }
    else if (self.model.state & ZZGridCellViewModelStateVideoDownloading)
    {
        [self _setupDownloadedStateWithModel:model];
    }
    else if (self.model.state & ZZGridCellViewModelStateVideoDownloaded)
    {
        [self.animationView finishDownloadingToView:self.numberBadge completion:^{
            [self _setupNumberBadgeWithModel:model];
        }];
    }
    else
    {
        [self _setupNumberBadgeWithModel:model];
    }
}

- (void)_setupDownloadedStateWithModel:(ZZGridCellViewModel*)model
{
    [self showDownloadAnimationWithCompletionBlock:^{

    }];
    
}

- (void)_setupNumberBadgeWithModel:(ZZGridCellViewModel*)model
{
    if (model.state & ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne)
    {
        if (model.badgeNumber > 0 && ![self.model isVideoPlayed])
        {
            [self updateBadgeWithNumber:model.badgeNumber];
        }
    }
    else if (model.state & ZZGridCellViewModelStateVideoCountMoreThatOne)
    {
        [self updateBadgeWithNumber:model.badgeNumber];
    }
    else if (model.state & ZZGridCellViewModelStateNeedToShowBorder)
    {
        [self updateBadgeWithNumber:model.badgeNumber];
    }
    else if (model.state & ZZGridCellViewModelStateVideoFirstVideoDownloading)
    {

    }
    else if ((model.state & ZZGridCellViewModelStatePreview) &&
             (model.state & ZZGridCellViewModelStateVideoDownloading))
    {
        [self updateBadgeWithNumber:model.badgeNumber];
    }
    else
    {
        [self updateBadgeWithNumber:model.badgeNumber];
    }

}

#pragma mark - Animation Views

- (CGFloat)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth,
                 kLayoutConstIndicatorFractionalWidth * kGridItemSize().width);
}


#pragma mark - Animation part

- (void)showUploadAnimationWithCompletionBlock:(void(^)())completionBlock;
{
    [self.effectView showEffect:ZZCellEffectTypeWaveIn];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self updateSendBadgePosition];
        
        [self.animationView animateWithType:ZZLoadingAnimationTypeUploading
                                     toView:self.sentBadge
                                 completion:^{
                                     self.sentBadge.hidden = NO;
                                     [self.sentBadge animate];
                                     
                                    completionBlock();
                                 }];
    });
}

- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock
{
    [self.animationView startDownloading];
}

- (void)_showVideoCountLabelWithCount:(NSInteger)count
{
    BOOL shouldAnimate = self.numberBadge.count < count;
    
    self.numberBadge.hidden = NO;
    self.numberBadge.count = count;
    
    if (shouldAnimate)
    {
        [self.numberBadge animate];
    }
}

- (void)_hideVideoCountLabel
{
    self.numberBadge.count = 0;
    [self updateSendBadgePosition];
    self.numberBadge.hidden = YES;
}

- (void)updateBadgeWithNumber:(NSInteger)badgeNumber
{
    
    if (badgeNumber > 0)
    {
        if (!self.isSentBadgeShifted)
        {
            self.sentBadge.hidden = YES;
        }
        
        [self _showVideoCountLabelWithCount:badgeNumber];
    }
    else
    {
        [self _hideVideoCountLabel];
    }
}

- (void)showAppearAnimation
{
    CAShapeLayer *oval = [CAShapeLayer layer];
    oval.delegate = self;
    oval.backgroundColor = [UIColor clearColor].CGColor;
    
    CGFloat diameter = self.frame.size.width + self.frame.size.height;
    
    CGRect rect = CGRectMake((self.frame.size.width - diameter) /2,
                             (self.frame.size.height - diameter) /2,
                             diameter,
                             diameter);
    
    oval.path = CGPathCreateWithEllipseInRect(rect, nil);
    oval.fillColor = [UIColor blackColor].CGColor;
    oval.frame = self.bounds;
    
    self.layer.mask = oval;
    
    oval.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    oval.transform = CATransform3DIdentity;

}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if ([event isEqualToString:@"transform"])
    {
        if (CATransform3DEqualToTransform(self.layer.mask.transform, CATransform3DIdentity))
        {
            return nil;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = [NSValue valueWithCATransform3D:self.layer.mask.transform];
        animation.duration = 1;
        return animation;
    }
    
    return nil;
}

#pragma mark - Lazy Load

- (UIView *)backgroundView
{
    
    if (_backgroundView)
    {
        return _backgroundView;
    }
    
    UIImageView *backgroundView = [UIImageView new];
    backgroundView.image = [UIImage imageNamed:@"pattern"];
    backgroundView.clipsToBounds = YES;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    switch (arc4random_uniform(3) ) {
        case 0:
            backgroundView.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor1;
            backgroundView.tintColor = [ZZColorTheme shared].gridCellTintColor1;
            break;
        case 1:
            backgroundView.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor2;
            backgroundView.tintColor = [ZZColorTheme shared].gridCellTintColor2;
            break;
        case 2:
            backgroundView.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor3;
            backgroundView.tintColor = [ZZColorTheme shared].gridCellTintColor3;
            break;
            
        default:
            break;
    }
    
    [self addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _backgroundView.hidden = YES;
    _backgroundView = backgroundView;
    return _backgroundView;

}

- (ZZNumberBadge *)numberBadge
{
    if (!_numberBadge)
    {
        _numberBadge = [ZZNumberBadge new];
        [self addSubview:_numberBadge];

        [_numberBadge mas_makeConstraints:^(MASConstraintMaker *make) {
            [self makePositionForFirstBadge:make];
        }];
        
        [_numberBadge layoutIfNeeded];
    }
    return _numberBadge;
}

- (ZZSentBadge *)sentBadge
{
    if (_sentBadge)
    {
        return _sentBadge;
    }
    
    _sentBadge = [ZZSentBadge new];
    _sentBadge.hidden = YES;
    [self addSubview:_sentBadge];
    
    [self updateSendBadgePosition];
    
    return _sentBadge;
}

- (void)updateSendBadgePosition
{
    [self.sentBadge mas_updateConstraints:^(MASConstraintMaker *make) {
        [self makePositionForSentBadge:make];
    }];
    
    [self.sentBadge layoutIfNeeded];
}

- (void)makePositionForSentBadge:(MASConstraintMaker *)maker
{
    self.isSentBadgeShifted = self.model.badgeNumber > 0;
    
    if (self.isSentBadgeShifted)
    {
        [self makePositionForSecondBadge:maker];
    }
    else
    {
        [self makePositionForFirstBadge:maker];
    }
}

- (void)makePositionForFirstBadge:(MASConstraintMaker *)maker
{
    maker.right.equalTo(self).offset(9);
    maker.top.equalTo(self).offset(-9);
}

- (void)makePositionForSecondBadge:(MASConstraintMaker *)maker
{
    maker.right.equalTo(self).offset(-20);
    maker.top.equalTo(self).offset(-9);
}

- (ZZLoadingAnimationView *)animationView
{
    if (_animationView)
    {
        return _animationView;
    }
    
    _animationView = [ZZLoadingAnimationView new];
    
    [self addSubview:_animationView];
    
    [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    return _animationView;
}

- (ZZUserNameLabel*)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [ZZUserNameLabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [ZZColorTheme shared].gridCellTextColor;
        _userNameLabel.font = [UIFont zz_regularFontWithSize:kUserNameFontSize];

        [self addSubview:_userNameLabel];

        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(kLayoutConstNameLabelHeight));
        }];
    }
    return _userNameLabel;
}

- (UIView *)backGradientView
{
    if (!_backGradientView)
    {
        ZZGridCellGradientView *view = [ZZGridCellGradientView new];
        
        _backGradientView = view;
        
        [self addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return _backGradientView;
}

- (ZZCellEffectView *)effectView
{
    if (_effectView)
    {
        return _effectView;
    }
    
    ZZCellEffectView *holdEffectView = [ZZCellEffectView new];
    [self addSubview:holdEffectView];
    [holdEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [holdEffectView layoutIfNeeded];
    holdEffectView.userInteractionEnabled = NO;
    
    _effectView = holdEffectView;
    
    return holdEffectView;
}

//- (DownloadingView *)downloadingView
//{
//    if (!_downloadingView)
//    {
//        _downloadingView = [[DownloadingView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
//    }
//    
//    return _downloadingView;
//}

#pragma mark Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.effectView showEffect:ZZCellEffectTypeWaveOut];
    [super touchesBegan:touches withEvent:event];
}

@end
