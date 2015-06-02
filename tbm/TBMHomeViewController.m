//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+VersionController.h"
#import "TBMHomeViewController+Invite.h"

#import "TBMAppDelegate+AppSync.h"

#import "HexColor.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMSecretGestureRecognizer.h"

@interface TBMHomeViewController ()
@property(nonatomic) TBMAppDelegate *appDelegate;
@property(nonatomic) TBMBenchViewController *benchViewController;
@property(nonatomic) UIView *overlayBackgroundView;
@property UIView *headerView;
@property UIView *contentView;
@property(nonatomic, strong) TBMSecretScreenPresenter *secretScreen;

@property(nonatomic, strong) UIView *logoView;
@property(nonatomic, strong) UIView *menuIconView;

@end

@implementation TBMHomeViewController

//--------------
#pragma mark - Instantiation
//--------------
static TBMHomeViewController *hvcInstance;

+ (TBMHomeViewController *)existingInstance {
    return hvcInstance;
}

- (TBMSecretScreenPresenter *)secretScreen {
    if (!_secretScreen) {
        _secretScreen = [[TBMSecretScreenPresenter alloc] init];
    }
    return _secretScreen;
}

- (UIView *)logoView {
    if (!_logoView) {
        UIImage *logoImage = [UIImage imageNamed:@"zazo-type"];
        CGFloat logoAspect = logoImage.size.width / logoImage.size.height;
        CGFloat top = (LayoutConstHEADER_HEIGHT - LayoutConstLOGO_HEIGHT) / 2;
        CGRect frame = CGRectMake(LayoutConstGUTTER, top, logoAspect * LayoutConstLOGO_HEIGHT, LayoutConstLOGO_HEIGHT);
        _logoView = [[UIView alloc] initWithFrame:frame];

        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        logoImageView.frame = _logoView.bounds;
        [_logoView addSubview:logoImageView];
        _logoView.userInteractionEnabled = YES;
    }
    return _logoView;
}

- (UIView *)menuIconView {
    if (!_menuIconView) {
        _menuIconView = [[UIView alloc] init];
        UIImage *i = [UIImage imageNamed:@"icon-drawer"];
        float aspect = i.size.width / i.size.height;
        UIImageView *iv = [[UIImageView alloc] initWithImage:i];
        float w = aspect * LayoutConstBENCH_ICON_HEIGHT;
        float x = self.view.bounds.size.width - LayoutConstGUTTER - w;
        float y = (LayoutConstHEADER_HEIGHT - LayoutConstBENCH_ICON_HEIGHT) / 2;
        CGRect frame= CGRectMake(x, y, w, LayoutConstBENCH_ICON_HEIGHT);
        _menuIconView.frame = frame;
        iv.frame = _menuIconView.bounds;
        _menuIconView.userInteractionEnabled = YES;
        [_menuIconView addSubview:iv];
    }
    return _menuIconView;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
    [super viewDidLoad];
    hvcInstance = self;
    [self addHomeViews];
    [self setupSecretGestureRecognizer];
    [[[TBMVersionHandler alloc] initWithDelegate:self] checkVersionCompatibility];
}

- (void)viewWillAppear:(BOOL)animated {
    OB_INFO(@"TBMHomeViewController: viewWillAppear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    OB_INFO(@"TBMHomeViewController: viewDidAppear");
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(prefetchContactsManager) withObject:NULL];
}


#pragma mark - Secret screen

- (void)setupSecretGestureRecognizer {
    TBMSecretGestureRecognizer *secretGestureRecognizer;
    secretGestureRecognizer = [[TBMSecretGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(secretGestureAction:)];
    secretGestureRecognizer.container = self.headerView;
    secretGestureRecognizer.logoView = self.logoView;
    secretGestureRecognizer.menuView = self.menuIconView;
    [self.view addGestureRecognizer:secretGestureRecognizer];
}

- (void)secretGestureAction:(id)sender {
    TBMSecretGestureRecognizer *recognizer = sender;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        OB_INFO(@"TBMHomeViewController#showSecretScreen");
        [self.secretScreen presentSecretScreenFromController:self];
    }
}


- (void)prefetchContactsManager {
//    [[TBMContactsManager sharedInstance] prefetchOnlyIfHasAccess];
}


- (void)didReceiveMemoryWarning {
    OB_ERROR(@"TBMHomeViewController: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}
#pragma mark - SetupViews

static const float LayoutConstHEADER_HEIGHT = 55;
static const float LayoutConstLOGO_HEIGHT = LayoutConstHEADER_HEIGHT * 0.4;
static const float LayoutConstGUTTER = 10;
static const float LayoutConstBENCH_ICON_HEIGHT = LayoutConstHEADER_HEIGHT * 0.4;

- (void)addHomeViews {
    [self addHeaderView];
    [self addContentView];
    [self addGridViewController];
    [self addOverlayBackgroundView];
    [self addBenchViewController];
}

#pragma mark - HeaderView

- (void)addHeaderView {
    UIView *hv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, LayoutConstHEADER_HEIGHT)];
    hv.backgroundColor = [UIColor colorWithHexString:@"1B1B19" alpha:1];
    [hv addSubview:self.logoView];
    [hv bringSubviewToFront:self.logoView];

    [hv addSubview:self.menuIconView];
    [hv bringSubviewToFront:self.menuIconView];

    [hv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)]];
    [self.view addSubview:hv];
    self.headerView = hv;

}

- (void)headerTapped {
    [self.benchViewController toggle];
}

#pragma mark - ContentView

- (void)addContentView {
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, LayoutConstHEADER_HEIGHT, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - LayoutConstHEADER_HEIGHT)];
    cv.backgroundColor = [UIColor colorWithHexString:@"2E2D28" alpha:1];
    [self.view addSubview:cv];
    self.contentView = cv;
}

- (void)addGridViewController {
    self.gridViewController = [[TBMGridViewController alloc] init];
    [self addChildViewController:self.gridViewController];
    self.gridViewController.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:self.gridViewController.view];
}

- (void)addBenchViewController {
    self.benchViewController = [[TBMBenchViewController alloc] initWithContainerView:self.contentView
                                                                  gridViewController:self.gridViewController];
    self.benchViewController.delegate = self;
    [self addChildViewController:self.benchViewController];
    [self.contentView addSubview:self.benchViewController.view];
}

- (void)addOverlayBackgroundView {
    self.overlayBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    self.overlayBackgroundView.backgroundColor = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:0.8f];
    [self.contentView addSubview:self.overlayBackgroundView];
    self.overlayBackgroundView.alpha = 0;
    self.overlayBackgroundView.hidden = YES;
}

#pragma mark - TBMBenchViewControllerDelegate

- (void)TBMBenchViewController:(TBMBenchViewController *)vc toggledHidden:(BOOL)isHidden {
    if (isHidden) {
        [UIView animateWithDuration:0.33f animations:^{
            self.overlayBackgroundView.alpha = 0;
        }                completion:^(BOOL finished) {
            self.overlayBackgroundView.hidden = YES;
        }];
    } else {
        self.overlayBackgroundView.hidden = NO;
        [UIView animateWithDuration:0.33f animations:^{
            self.overlayBackgroundView.alpha = 0.8;
        }];
    }
}


@end
