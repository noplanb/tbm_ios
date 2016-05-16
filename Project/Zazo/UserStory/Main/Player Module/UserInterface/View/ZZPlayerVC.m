//
//  ZZPlayerVC.m
//  Zazo
//

@import AVKit;
@import AVFoundation;

#import "ZZPlayerVC.h"
#import "ZZPlayer.h"
#import "ZZPlayerBackgroundView.h"

@interface ZZPlayerVC ()

@property (nonatomic, strong) ZZPlayerBackgroundView *contentView;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong, readonly) UIView *baseView;

@end

@implementation ZZPlayerVC

@synthesize playerController = _playerController;

- (void)loadView
{
    self.contentView = [ZZPlayerBackgroundView new];
    self.view = self.contentView;
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self _makeBaseView];

    self.contentView.presentingView = self.presentingViewController.view;
}

- (void)_makeBaseView
{
    if (!self.playerController.view)
    {
        return;
    }
    
    if (!self.baseView)
    {
        _baseView = [UIView new];
        _baseView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_baseView];
        
        [self.view bringSubviewToFront:self.playerController.view];
        
        _baseView.layer.cornerRadius = 4;
        _baseView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
        _baseView.layer.borderWidth = 4;
    }
    
    self.baseView.frame = CGRectMake(self.playerController.view.frame.origin.x - 4,
                                     self.playerController.view.frame.origin.y - 4,
                                     self.playerController.view.frame.size.width + 8,
                                     self.playerController.view.frame.size.height + 8);

}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.view.userInteractionEnabled = YES;
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [super viewDidLoad];
    
}

- (void)setPlayerController:(AVPlayerViewController *)playerController
{
    [_playerController.view removeFromSuperview];
    
    _playerController = playerController;
    
    [self.view addSubview:playerController.view];
    [_playerController.view addSubview:self.tapButton];

    _playerController.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerController.view.backgroundColor = [UIColor clearColor];
    _playerController.showsPlaybackControls = NO;
}

- (UIButton *)tapButton
{
    if (!_tapButton)
    {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapButton addTarget:self.eventHandler
                       action:@selector(playerWasTapped)
             forControlEvents:UIControlEventTouchUpInside];
        [self.playerController.view addSubview:_tapButton];
        
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerController.view);
        }];
    }
    return _tapButton;
}

@end
