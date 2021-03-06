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
#import "ZZVideoDataProvider.h"
#import "ZZGridCell.h"

@interface ZZGridStateView ()

@property (nonatomic, assign) BOOL isSentBadgeShifted;
@property (nonatomic, assign) UIImage *backgroundImage;

@end

@implementation ZZGridStateView

- (instancetype)initWithPresentedView:(ZZGridCell *)presentedView
{
    self = [super init];
    if (self)
    {
        self.backgroundImage = [UIImage imageNamed:@"pattern"];
        self.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor1;
        self.presentedView = presentedView;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_didTapVideo:)];
        
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel *)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;

        if (self.model.videoState == ZZCellVideoStateUploaded)
        {
            [self updateSendBadgePosition];
            self.sentBadge.hidden = NO;
        }

        [self _setupNumberBadgeWithModel:model];

        model.playerContainerView = self;

        model.usernameLabel = self.userNameLabel;
        [self.model reloadDebugVideoStatus];

        self.sentBadge.state = model.videoState == ZZCellVideoStateViewed ? ZZSentBadgeStateViewed : ZZSentBadgeStateSent;
        self.sentBadge.hidden = !(model.videoState == ZZCellVideoStateViewed || model.videoState == ZZCellVideoStateUploaded);
        
        [self _setupDownloadAnimationsWithModel:model];
    });
}


#pragma mark - Downloaded Animation behavior

- (void)_setupDownloadAnimationsWithModel:(ZZGridCellViewModel *)model
{
    switch (self.model.videoState) {
            
        case ZZCellVideoStateDownloading:
            [self _showDownloadAnimationIfNeeded];
            break;
            
        case ZZCellVideoStateFailed:
        case ZZCellVideoStateDownloaded:
            [self _finishDownloadAnimationIfNeeded];
            break;
            
        default:
            break;
    }

}
             
- (void)_finishDownloadAnimationIfNeeded
{
    if ([self _countOfDownloadsForModel:self.model] != 0)
    {
        return;
    }
    
    [self.animationView finishDownloadingToView:self.numberBadge completion:nil];
}

- (void)_showDownloadAnimationIfNeeded
{
    if ([ZZVideoDataProvider countVideosWithStatus:ZZVideoIncomingStatusDownloading
                                        fromFriend:self.model.item.relatedUser.idTbm] > 1)
    {
        return; // No need show animation again if already downloading
    }
    
    [self showDownloadAnimation];
}

- (NSUInteger)_countOfDownloadsForModel:(ZZGridCellViewModel *)gridModel
{
    return [ZZVideoDataProvider countVideosWithStatus:ZZVideoIncomingStatusDownloading
                                           fromFriend:gridModel.item.relatedUser.idTbm];

}

- (void)_setupNumberBadgeWithModel:(ZZGridCellViewModel *)model
{
    [self updateBadgeWithNumber:model.badgeNumber];
}

- (void)_didTapVideo:(UITapGestureRecognizer *)recognizer
{
    if (!self.superview.isHidden && [self.model isEnablePlayingVideo])
    {
//        [self.presentedView hideActiveBorder];
        [self.model didTapCell];
    }
}

#pragma mark - Animation part

- (void)showUploadAnimationWithCompletionBlock:(void (^)())completionBlock;
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

- (void)showDownloadAnimation
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

    CGRect rect = CGRectMake((self.frame.size.width - diameter) / 2,
            (self.frame.size.height - diameter) / 2,
            diameter,
            diameter);

    oval.path = CGPathCreateWithEllipseInRect(rect, nil);
    oval.fillColor = [UIColor blackColor].CGColor;
    oval.frame = self.bounds;

    self.layer.mask = oval;

    oval.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    oval.transform = CATransform3DIdentity;

}

- (nullable id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if ([event isEqualToString:@"transform"])
    {
        if (CATransform3DEqualToTransform(self.layer.mask.transform, CATransform3DIdentity))
        {
            return nil;
        }

        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = [NSValue valueWithCATransform3D:self.layer.mask.transform];
        animation.duration = 0.8;
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
    backgroundView.layer.shouldRasterize = YES;
    backgroundView.image = self.backgroundImage;
    backgroundView.clipsToBounds = YES;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;

    switch (arc4random_uniform(3))
    {
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
//    _backgroundView.hidden = YES;
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

- (ZZUserNameLabel *)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [ZZUserNameLabel new];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.textColor = [ZZColorTheme shared].gridCellTextColor;
        _userNameLabel.font = [UIFont zz_regularFontWithSize:kUserNameFontSize];

        [self addSubview:_userNameLabel];

        CGFloat offset = 8;
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(offset);
            make.right.equalTo(self).offset(-offset);
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


- (UIButton *)overflowButton
{
    if (!_overflowButton) {
        
        UIButton *button = [UIButton new];
        
        [self addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(kLayoutConstNameLabelHeight));
        }];
        
        [button addTarget:self
                   action:@selector(didTapOverflowButton:)
         forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *overflowIcon = [UIImage imageNamed:@"overflow-icon"];
        
        UIImageView *overflowImageView = [[UIImageView alloc] initWithImage:overflowIcon];
        overflowImageView.tintColor = [UIColor whiteColor];
        
        [button addSubview:overflowImageView];
        [overflowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button);
            make.right.equalTo(button);
        }];
        
        _overflowButton = button;
    }
    
    return _overflowButton;
}

- (void)didTapOverflowButton:(UIButton *)button
{
    [self.model didTapOverflowButton:(UIButton *)button];
}

#pragma mark Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.effectView showEffect:ZZCellEffectTypeWaveOut];
    [super touchesBegan:touches withEvent:event];
}

@end
