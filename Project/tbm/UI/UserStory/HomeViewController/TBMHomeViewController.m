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
#import "ANMessagesWireframe.h"
#import "HexColors.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMSecretGestureRecognizer.h"
#import "TBMEventsFlowModulePresenter.h"
#import "ZZEditFriendListWireframe.h"
#import "ANMessageDomainModel.h"
#import "DeviceUtil.h"
#import "TBMUser.h"

typedef NS_ENUM(NSInteger, ZZEditMenuButtonType)
{
    ZZEditMenuButtonTypeEditFriends = 0,
    ZZEditMenuButtonTypeSendFeedback = 1,
    ZZEditMenuButtonTypeCancel = 2,
};

@interface TBMHomeViewController () <UIActionSheetDelegate>
@property (nonatomic) TBMAppDelegate *appDelegate;
//@property (nonatomic) TBMBenchViewController *benchViewController;
@property (nonatomic) UIView *overlayBackgroundView;
//@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
//@property (nonatomic, strong) UIView *logoView;
//@property (nonatomic, strong) UIButton *editFriendsButton;
//@property(nonatomic, strong) UIView *menuButton;
@property(nonatomic) BOOL isPlaying;
@property (nonatomic, strong) ANMessagesWireframe* emailWireframe;
@property (nonatomic, strong) ZZEditFriendListWireframe* editFriendsWireframe;

@property(nonatomic) BOOL isSMSProcessActive; // this means if sms composer presented on screen.
// Modules
@property(nonatomic, strong) TBMSecretScreenPresenter *secretScreen;
@property(nonatomic, strong) id <TBMEventsFlowModuleInterface> eventsFlowModule;

@end

@implementation TBMHomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
    [super viewDidLoad];
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
//    [[self.dependencies setupDependenciesWithHomeViewController:self];
    self.isSMSProcessActive = NO;
    [self registerToNotifications];
//    hvcInstance = self;
    [self addHomeViews];
//    [self setupSecretGestureRecognizer];
    [[[TBMVersionHandler alloc] initWithDelegate:self] checkVersionCompatibility];
}

- (void)registerToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationDidEnterBackground
{
//    [self.benchViewController hide];
    if (!self.isSMSProcessActive) {
        [self.eventsFlowModule resetSession];
    }
}

- (void)applicationDidEnterForeground
{
    if (!self.isSMSProcessActive) {

    }

    self.isSMSProcessActive = NO;
}


#pragma mark - SetupViews

//static const float kLayoutHeaderheight = 55;
//static const float kLayoutLogoHeight = kLayoutHeaderheight * 0.4;
//static const float kLayoutGutter = 10;
//static const float kLayoutBenchIconHeight = kLayoutHeaderheight * 0.4;

- (void)addHomeViews
{
//    [self headerView];
//    [self addContentView];
    [self addGridViewController];
//    [self addOverlayBackgroundView];
//    [self addBenchViewController];
}

#pragma mark - ContentView

//- (void)addContentView {
//    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, kLayoutHeaderheight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kLayoutHeaderheight)];
//    cv.backgroundColor = [UIColor colorWithHexString:@"2E2D28" alpha:1];
//    [self.view addSubview:cv];
//    self.contentView = cv;
//}

- (void)addGridViewController {
    self.gridViewController = [[TBMGridViewController alloc] init];
    self.gridViewController.frame = self.contentView.bounds;
    self.gridViewController.homeView = self.view;
    self.gridViewController.delegate = self;
    [self addChildViewController:self.gridViewController];
    [self.contentView addSubview:self.gridViewController.view];
    [self.eventsFlowModule setupGridModule:self.gridViewController];
}

#pragma mark - TBMGridDelegate

- (void)videoPlayerDidStartPlaying:(TBMVideoPlayer *)player {
    self.isPlaying = YES;
}

- (void)videoPlayerDidStopPlaying:(TBMVideoPlayer *)player {
    if (self.isPlaying) {
        self.isPlaying = NO;
    }
}

- (void)applicationWillSwitchToSMS {
    self.isSMSProcessActive = YES;
}


#pragma mark Interface

//- (void)showBench {
//    if (!self.benchViewController.isShowing) {
//        [self.benchViewController toggle];
//    }
//}

#pragma mark - UIActionSheetDelegate

//- (void)menuButtonTaped:(id)sender {
//    [self.benchViewController toggle];
//}

//- (void)editFriendButtonTapped:(UIButton *)sender
//{
//    NSString *editFriendsButtonTitle = NSLocalizedString(@"grid-controller.menu.edit-friends.button.title", nil);
//    NSString *sendFeedbackButtonTitle = NSLocalizedString(@"grid-controller.menu.send-feedback.button.title", nil);
//    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:editFriendsButtonTitle, sendFeedbackButtonTitle, nil] showInView:self.view];
//}


//- (void)addBenchViewController {
//    self.benchViewController = [[TBMBenchViewController alloc] initWithContainerView:self.contentView
//                                                                  gridViewController:self.gridViewController];
//    self.benchViewController.delegate = self;
//    [self addChildViewController:self.benchViewController];
//    [self.contentView addSubview:self.benchViewController.view];
//}

//- (void)addOverlayBackgroundView {
//    self.overlayBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
//    self.overlayBackgroundView.backgroundColor = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:0.8f];
//    [self.contentView addSubview:self.overlayBackgroundView];
//    self.overlayBackgroundView.alpha = 0;
//    self.overlayBackgroundView.hidden = YES;
//}

//#pragma mark - TBMBenchViewControllerDelegate
//
//- (void)TBMBenchViewController:(TBMBenchViewController *)vc toggledHidden:(BOOL)isHidden {
//    if (isHidden) {
//        [UIView animateWithDuration:0.33f animations:^{
//            self.overlayBackgroundView.alpha = 0;
//        }                completion:^(BOOL finished) {
//            self.overlayBackgroundView.hidden = YES;
//        }];
//    } else {
//        self.overlayBackgroundView.hidden = NO;
//        [UIView animateWithDuration:0.33f animations:^{
//            self.overlayBackgroundView.alpha = 0.8;
//        }];
//    }
//}



#pragma mark - DEPENDENCIES PART
//TODO: move to dependencies class

//
//- (TBMSecretScreenPresenter *)secretScreen {
//    if (!_secretScreen) {
//        _secretScreen = [[TBMSecretScreenPresenter alloc] init];
//        [_secretScreen assignTutorialModule:self.eventsFlowModule];
//    }
//    return _secretScreen;
//}
//
//- (TBMDependencies *)dependencies
//{
//    if (!_dependencies)
//    {
//        _dependencies = [TBMDependencies new];
//    }
//    return _dependencies;
//}


#pragma mark - UIActionSheetDelegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex) {
//            
//        case ZZEditMenuButtonTypeEditFriends:
//        {
//            self.editFriendsWireframe = [ZZEditFriendListWireframe new];
//            self.benchViewController.view.hidden = YES;
//            [self.editFriendsWireframe presentEditFriendListControllerFromViewController:self withCompletion:^{
//                self.benchViewController.view.hidden = NO;
//            }];
//            
//        } break;
//            
//        case ZZEditMenuButtonTypeSendFeedback:
//        {
//            ANMessageDomainModel *model = [ANMessageDomainModel new];
//            model.title = emailSubject;
//            model.recipients = @[emailAddress];
//            model.isHTMLMessage = YES;
//            model.message = [NSString stringWithFormat:@"<font color = \"000000\"></br></br></br>---------------------------------</br>iOS: %@</br>Model: %@</br>User mKey: %@</br>App Version: %@</br>Build Version: %@ </font>", [[UIDevice currentDevice] systemVersion], [DeviceUtil hardwareDescription], [TBMUser getUser].mkey, [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleVersionKey]];
//            
//            self.emailWireframe = [ANEmailWireframe new];
//            [self.emailWireframe presentEmailControllerFromViewController:self withModel:model completion:nil];
//            
//        } break;
//            
//        case ZZEditMenuButtonTypeCancel:
//        {
//            
//        } break;
//            
//        default:
//            break;
//    }
//}



@end
