//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+VersionController.h"
#import "TBMHomeViewController+Bench.h"
#import "TBMHomeViewController+Grid.h"
#import "TBMHomeViewController+Invite.h"
#import "TBMGridElement.h"
#import "TBMLongPressTouchHandler.h"
#import "TBMVideoPlayer.h"
#import <UIKit/UIKit.h>
#import "TBMAppDelegate+AppSync.h"
#import "OBLogger.h"
#import "TBMContactsManager.h"

@interface TBMHomeViewController ()
@property TBMLongPressTouchHandler *longPressTouchHandler;
@property (nonatomic) TBMAppDelegate *appDelegate;
@property BOOL isPlaying;
@property TBMVideoRecorder *videoRecorder;
@end


@implementation TBMHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil obbundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------
// Events called in by appDelegate
//--------------------------------
- (TBMAppDelegate *)appDelegate{
    return self.appDelegate = (TBMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Not used
- (void)appDidBecomeActive{
    if ([self isViewLoaded] && self.view.window) {
        // viewController is visible
        OB_INFO(@"appDidBecomeActive: calling setupVideoRecorder:0");
        [self setupVideoRecorder:0];
    } else {
        OB_WARN(@"appDidBecomeActive: not setting up VideoRecorder because !self.isViewLoaded && self.view.window");
    }
}

// Not used
- (void)appWillEnterForeground{
}


//-----------------------------
// Events on the viewController
//-----------------------------
- (void)viewDidLoad{
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
    [super viewDidLoad];
    [TBMFriend addVideoStatusNotificationDelegate:self];
    [self setupGrid];
    [self setupLongPressTouchHandler];
    [self addBenchGestureRecognizers];
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
    [self setupVideoRecorder:0];
    [self performSelectorInBackground:@selector(prefetchContactsManager) withObject:NULL];
}

- (void) prefetchContactsManager{
    [[TBMContactsManager sharedInstance] prefetchOnlyIfHasAccess];
}

- (void) viewWillDisappear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: viewWillDisappear");
    // Eliminated videoRecorder.dispose here. The OS takes care of interrupting or stopping and restarting our VideoCaptureSession very well.
    // We don't need to interfere with it.
}

- (void) didReceiveMemoryWarning{
    OB_ERROR(@"TBMHomeViewController: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//------
// Setup
//------


//---------------------------
// setup LonpressTouchHandler
//---------------------------

- (void)setupLongPressTouchHandler{
    _longPressTouchHandler = [[TBMLongPressTouchHandler alloc] initWithTargetViews:_gridViews instantiator:self];
}



//-----------------------------------
// VideoRecorder setup and callbacks
//-----------------------------------
- (void)didFinishVideoRecordingWithMarker:(NSString *)friendId{
    DebugLog(@"didFinishVideoRecordingWithFriendId %@", friendId);
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    [friend handleAfterOutgoingVideoCreated];
    [[self appDelegate] uploadWithFriendId:friendId];
}

- (void)videoRecorderDidStartRunning{
    [self  setRecordingIndicatorTextForRecording];
    [self hideRecordingIndicator];
}

- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount{
    OB_ERROR(@"videoRecorderRuntimeErrorWithRetryCount %d", videoRecorderRetryCount);
    [self setupVideoRecorder:videoRecorderRetryCount];
}

// We call setupVideoRecorder on multiple events so the first qualifying event takes effect. All later events are ignored.
- (void)setupVideoRecorder:(int)retryCount{
    // Note that when we get retryCount != 0 we are being called because of a videoRecorderRuntimeError and we need reinstantiate
    // even if videoRecorder != nil
    // Also if we still have a videoRecorder but the OS killed our view from under us trying to save memory while we were in the
    // background we want to reinstantiate.
    if (self.videoRecorder != nil && retryCount == 0  && [self isViewLoaded] && self.view.window){
        OB_WARN(@"TBMHomeViewController: setupVideoRecorder: already setup. Ignoring");
        return;
    }
    
    if (![self appDelegate].isForeground){
        OB_WARN(@"HomeViewController: not initializing the VideoRecorder because ! isForeground");
        return;
    }
    OB_WARN(@"HomeviewController: setupVideoRecorder: setting up. vr=%@, rc=%d, isViewLoaded=%d, view.window=%d", self.videoRecorder, retryCount, [self isViewLoaded], [self isViewLoaded] && self.view.window);
    NSError *error = nil;
    [self setRecordingIndicatorTextForRecorderSetup:retryCount];
    [self showRecordingIndicator];
    self.videoRecorder = [[TBMVideoRecorder alloc] initWithPreviewView:self.centerView delegate:self error:&error];
}

- (void)setRecordingIndicatorTextForRecorderSetup:(int)retryCount{
    NSString *msg;
    if (retryCount == 0)
         msg = @"c...";
    else
        msg = [NSString stringWithFormat: @"c r%d", retryCount];
    self.centerLabel.text = msg;
}

- (void)setRecordingIndicatorTextForRecording{
    self.centerLabel.text = @"Recording...";
}

- (void)showRecordingIndicator{
    _centerLabel.hidden = NO;
}

- (void)hideRecordingIndicator{
    _centerLabel.hidden = YES;
}


//-----------------------------------
// TBMVideoStatusNotoficationProtocol
//-----------------------------------
-(void)videoStatusDidChange:(id)object{
    [self updateAllGridViews];
}

//------------------------------------------
// Longpress touch handling for friend views
//------------------------------------------
// We detect the touches for the entire window using this view controller but pass them to the longPressTouchHandler.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesCancelled:touches withEvent:event];
    }
}

// Callbacks per the TBMLongPressTouchHandlerCallback protocol.
- (void)LPTHClickWithTargetView:(UIView *)view{
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil){
        [self rankingActionOccurred:ge.friend];
        [[self videoPlayerWithView:view] togglePlay];
    } else {
        OB_INFO(@"Click on plus");
    }
}

- (void)LPTHStartLongPressWithTargetView:(UIView *)view{
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil){
        [self rankingActionOccurred:ge.friend];
        [[self videoRecorder] startRecordingWithMarker:ge.friend.idTbm];
        [self showRecordingIndicator];
    } else {
        OB_INFO(@"StartLongPress on plus");
    }
}

- (void)LPTHEndLongPressWithTargetView:(UIView *)view{
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil){
        [[self videoRecorder] stopRecording];
        [self hideRecordingIndicator];
    } else {
        OB_INFO(@"EndLongPress on plus");
    }
}

- (void)LPTHCancelLongPressWithTargetView:(UIView *)view{
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil){
        [[self videoRecorder] cancelRecording];
        [self hideRecordingIndicator];
    } else {
        OB_INFO(@"CancelLongPress on plus");
    }
}


//---------
// Show log
//---------
- (void)setupShowLogGesture{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLog:)];
    lpgr.delegate = (id)self;
    [self.centerView addGestureRecognizer:lpgr];
}

-(IBAction)showLog:(UILongPressGestureRecognizer *)sender{
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        OBLogViewController *logViewer = [OBLogViewController instance];
        [self presentViewController: logViewer animated:YES completion:nil];
    }
}

@end
