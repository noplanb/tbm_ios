//
//  ZZPlayerVC.m
//  Zazo
//

@import AVKit;
@import AVFoundation;

#import "ZZPlayerVC.h"
#import "ZZPlayer.h"
#import "ZZPlayerBackgroundView.h"
#import "ZZTabbarView.h"
#import "ZZGridActionStoredSettings.h"

@interface ZZPlayerVC ()

@property (nonatomic, strong) ZZPlayerBackgroundView *contentView;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong, readonly) UIView *baseView;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) VideoPlayerFullscreenHelper *fullscreenHelper;
@property (nonatomic, strong) AndroidButton *nextButton;

@end

@implementation ZZPlayerVC

@synthesize initialPlayerFrame = _initialPlayerFrame;
@synthesize playerView = _playerView;
@synthesize playbackIndicator = _playbackIndicator;

- (void)loadView
{
    self.contentView = [[ZZPlayerBackgroundView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = self.contentView;
    self.view.userInteractionEnabled = YES;
    
    [self dimView];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.contentView.presentingView = self.presentingViewController.view;
}

- (AndroidButton *)nextButton
{
    if (!_nextButton)
    {
        _nextButton = [[AndroidButton alloc] initWithAndroidButtonOfType:AndroidButtonTypeNext];
        [self.view addSubview:_nextButton];
        
        [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-16);
            make.bottom.equalTo(self.dimView).offset(-16);
        }];
        
        [_nextButton addTarget:self
                        action:@selector(didTapNextButton)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

- (UIButton *)tapButton
{
    if (!_tapButton)
    {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_tapButton addTarget:self.eventHandler
                       action:@selector(didTapVideo)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self.playerView addSubview:_tapButton];
        
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerView);
        }];
    }
    return _tapButton;
}

- (UIView *)dimView
{
    if (!_dimView)
    {
        _dimView = [UIView new];
        
        _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _dimView.userInteractionEnabled = NO;
        
        [self.view addSubview:_dimView];
        
        [_dimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, ZZTabbarViewHeight, 0));
        }];
        
    }
    
    return _dimView;
}

- (void)_makeBaseView
{
    if (!self.view)
    {
        return;
    }
    
    if (!self.baseView)
    {
        _baseView = [UIView new];
        _baseView.backgroundColor = [UIColor clearColor];
        _baseView.userInteractionEnabled = NO;
        
        [self.view addSubview:_baseView];
        
        [self.view bringSubviewToFront:self.playerView];
        [self.view bringSubviewToFront:self.playbackIndicator];
        
        _baseView.layer.cornerRadius = 4;
        _baseView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
        _baseView.layer.borderWidth = 4;
    }
    
    self.baseView.frame = CGRectMake(self.initialPlayerFrame.origin.x - 4,
                                     self.initialPlayerFrame.origin.y - 4,
                                     self.initialPlayerFrame.size.width + 8,
                                     self.initialPlayerFrame.size.height + 8);

}

- (void)viewDidLayoutSubviews
{
    [self.fullscreenHelper updateFrameAndAppearance];
    [self updateTextLabel];
}

- (void)viewDidLoad
{
    self.view.userInteractionEnabled = YES;
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [super viewDidLoad];
}

#pragma mark Events

- (void)didTapNextButton
{
    [self.eventHandler didTapNextMessageButton];
}

#pragma mark Properties


- (BOOL)isPlayerOnTop
{
    return self.initialPlayerFrame.origin.y < 50; // it may be ~0.00123
}

- (void)updateTextLabel
{
    [self.textLabel sizeToFit];
    
    CGPoint origin = self.initialPlayerFrame.origin;
    
    if ([self isPlayerOnTop])
    {
        origin.y += self.initialPlayerFrame.size.height + 12; // move label to cell's bottom
    }
    else
    {
        origin.y -= self.textLabel.height + 6; // move label to cell's top
    }
    
    origin.x -= 4; // move little bit left
    self.textLabel.origin = origin;
}

- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        
        [_dimView addSubview:label];
        
        _textLabel = label;
    }
    
    return _textLabel;
}

#pragma mark Input

- (void)setNextButtonVisible:(BOOL)flag
{
    self.nextButton.hidden = !flag;
    [self.view bringSubviewToFront:self.nextButton];
    [self.view bringSubviewToFront:self.playbackIndicator.superview];
}

- (void)setInitialPlayerFrame:(CGRect)initialPlayerFrame
{
    [self.dimView layoutIfNeeded];
    
    initialPlayerFrame.origin.y -= [UIApplication sharedApplication].statusBarFrame.size.height - 20.0f; // Hack for in-call statusbar
 
    CGFloat frameBottom = CGRectGetMaxY(initialPlayerFrame);
    CGFloat containerBottom = CGRectGetMaxY(self.view.frame);
    
    if (frameBottom > containerBottom)
    {
        initialPlayerFrame.size.height -= frameBottom - containerBottom; // shrink it a bit to fit in the container
    }
    
    _initialPlayerFrame = initialPlayerFrame;
    [self updateTextLabel];
    self.fullscreenHelper.initialFrame = initialPlayerFrame;
    [self _makeBaseView];

}

- (void)updatePlayerText:(NSString *)text
{
    self.textLabel.text = text;
    [self.textLabel sizeToFit];
}

- (void)setPlaybackIndicator:(UIView *)playbackIndicator
{
    _playbackIndicator = playbackIndicator;    
    
    UIView *indicatorBackground = [UIView new];
    indicatorBackground.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:indicatorBackground];
    
    [indicatorBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.dimView.mas_bottom);
        make.height.equalTo(@(ZZTabbarViewHeight));
    }];
    
    [indicatorBackground addSubview:playbackIndicator];
    
    [playbackIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(indicatorBackground.mas_leftMargin);
        make.right.equalTo(indicatorBackground.mas_rightMargin);
        make.top.equalTo(indicatorBackground);
        make.bottom.equalTo(indicatorBackground);
    }];
    
    RAC(playbackIndicator, hidden) = RACObserve([ZZGridActionStoredSettings shared], playbackControlsFeatureEnabled).not;
}

- (void)setPlayerView:(UIView *)playerView
{
    _playerView = playerView;
    [self.view addSubview:playerView];
    [playerView addSubview:self.tapButton];
    self.fullscreenHelper = [[VideoPlayerFullscreenHelper alloc] initWithView:playerView];
    RAC(self.fullscreenHelper, enabled) = RACObserve([ZZGridActionStoredSettings shared], fullscreenFeatureEnabled);
}

- (void)setFullscreenEnabled:(BOOL)enabled completion:(ANCodeBlock)completion;
{
    if (!completion)
    {
        completion = ^{};
    }
    
    if (!enabled && self.fullscreenHelper.isFullscreen)
    {
        [self.fullscreenHelper completeAnimatedToPosition:0
                                                 velocity:1
                                               completion:^(BOOL finished) {
            completion();
        }];
    }
    
    if (enabled && !self.fullscreenHelper.isFullscreen)
    {
        [self.fullscreenHelper completeAnimatedToPosition:0
                                                 velocity:1
                                               completion:^(BOOL finished) {
            completion();
        }];
    }

    else
    {
        completion();
    }
}

@end
