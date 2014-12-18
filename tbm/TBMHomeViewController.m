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
#import "TBMBenchViewController.h"
#import "TBMFriend.h"
#import "TBMVersionHandler.h"
#import "TBMGridElement.h"
#import "TBMVideoPlayer.h"

#import "TBMAppDelegate+AppSync.h"
#import "OBLogger.h"
#import "TBMContactsManager.h"

#import <UIKit/UIKit.h>
#import "HexColor.h"

@interface TBMHomeViewController ()
@property (nonatomic) TBMAppDelegate *appDelegate;
@property (nonatomic) TBMBenchViewController *benchViewController;

@property UIView *headerView;
@property UIView *contentView;
@end

@implementation TBMHomeViewController

//--------------
// Instantiation
//--------------
static TBMHomeViewController *hvcInstance;

+ (TBMHomeViewController *)existingInstance{
    return hvcInstance;
}

//----------
// Lifecycle
//----------
- (void)viewDidLoad{
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
    [super viewDidLoad];
    hvcInstance = self;
    [self addHomeViews];
    [self setupShowLogGesture];
    [[[TBMVersionHandler alloc] initWithDelegate:self] checkVersionCompatibility];
}

- (void)viewWillAppear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: viewWillAppear");
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: viewDidAppear");
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(prefetchContactsManager) withObject:NULL];
}

- (void) prefetchContactsManager{
    [[TBMContactsManager sharedInstance] prefetchOnlyIfHasAccess];
}


- (void) didReceiveMemoryWarning{
    OB_ERROR(@"TBMHomeViewController: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}


//===========
// SetupViews
//===========
static const float LayoutConstHEADER_HEIGHT = 55;
static const float LayoutConstLOGO_HEIGHT = LayoutConstHEADER_HEIGHT * 0.4;
static const float LayoutConstGUTTER = 10;
static const float LayoutConstBENCH_ICON_HEIGHT = LayoutConstHEADER_HEIGHT *0.4;

- (void) addHomeViews{
    [self addHeaderView];
    [self addContentView];
    [self addGridViewController];
    [self addBenchViewController];
}

//-----------
// HeaderView
//-----------
- (void)addHeaderView{
    UIView *hv =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, LayoutConstHEADER_HEIGHT)];
    hv.backgroundColor = [UIColor colorWithHexString:@"1B1B19" alpha:1];
    [hv addSubview:[self logoView]];
    [hv addSubview:[self drawerIconView]];
    [hv addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)]];
    [self.view addSubview:hv];
    self.HeaderView = hv;
}

- (void)headerTapped{
    [self.benchViewController toggle];
}

- (UIImageView *)logoView{
    UIImage *li = [UIImage imageNamed:@"zazo-type"];
    float logoAspect = li.size.width / li.size.height;
    UIImageView *lv = [[UIImageView alloc] initWithImage:li];
    float y = (LayoutConstHEADER_HEIGHT - LayoutConstLOGO_HEIGHT) / 2;
    lv.frame = CGRectMake(LayoutConstGUTTER, y, logoAspect * LayoutConstLOGO_HEIGHT, LayoutConstLOGO_HEIGHT);
    return lv;
}

- (UIImageView *)drawerIconView{
    UIImage *i = [UIImage imageNamed:@"icon-drawer"];
    float aspect = i.size.width / i.size.height;
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    float w = aspect * LayoutConstBENCH_ICON_HEIGHT;
    float x = self.view.bounds.size.width - LayoutConstGUTTER - w;
    float y = (LayoutConstHEADER_HEIGHT - LayoutConstBENCH_ICON_HEIGHT) / 2;
    iv.frame = CGRectMake(x, y, w, LayoutConstBENCH_ICON_HEIGHT);
    return iv;
}


//------------
// ContentView
//------------
- (void)addContentView{
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, LayoutConstHEADER_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - LayoutConstHEADER_HEIGHT)];
    cv.backgroundColor = [UIColor colorWithHexString:@"2E2D28" alpha:1];
    [self.view addSubview:cv];
    self.contentView = cv;
}

- (void)addGridViewController{
    self.gridViewController = [[TBMGridViewController alloc] init];
    [self addChildViewController:self.gridViewController];
    self.gridViewController.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:self.gridViewController.view];
}

- (void)addBenchViewController{
    self.benchViewController = [[TBMBenchViewController alloc] initWithContainerView:self.contentView
                                                                  gridViewController:self.gridViewController];
    [self addChildViewController:self.benchViewController];
    [self.contentView addSubview:self.benchViewController.view];
}


//---------
// Show log
//---------
- (void)setupShowLogGesture{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLog:)];
    lpgr.delegate = (id)self;
    [self.headerView addGestureRecognizer:lpgr];
}

-(IBAction)showLog:(UILongPressGestureRecognizer *)sender{
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        OBLogViewController *logViewer = [OBLogViewController instance];
        [self presentViewController: logViewer animated:YES completion:nil];
    }
}

@end
