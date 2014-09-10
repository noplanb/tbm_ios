//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+VersionController.h"

#import "TBMLongPressTouchHandler.h"
#import "TBMVideoPlayer.h"
#import <UIKit/UIKit.h>
#import "TBMAppDelegate+AppSync.h"
#import "OBLogger.h"

@interface TBMHomeViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *friendViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *friendLabels;
@property TBMLongPressTouchHandler *longPressTouchHandler;
@property TBMVideoPlayer *videoPlayer;
@property (nonatomic) TBMAppDelegate *appDelegate;
@property BOOL isPlaying;
@property TBMVideoRecorder *videoRecorder;
@end

static NSInteger TBM_HOME_FRIEND_VIEW_INDEX_OFFSET = 10;
static NSInteger TBM_HOME_FRIEND_LABEL_INDEX_OFFSET = 20;

@implementation TBMHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil obbundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (TBMAppDelegate *)appDelegate{
    return self.appDelegate = (TBMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad{
    OB_INFO(@"TBMHomeViewController: viewDidLoad");
    [super viewDidLoad];
    [TBMFriend addVideoStatusNotificationDelegate:self];
    [self setupFriendViews];
    [self setupVideoPlayers];
    [self setupLongPressTouchHandler];
    [self setupShowLogGesture];
    [[[TBMVersionHandler alloc] initWithDelegate:self] checkVersionCompatibility];
}

- (void)viewWillAppear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: viewWillAppear");
    [super viewWillAppear:animated];
    [self setupVideoRecorder:0];
}

- (void) viewDidAppear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: viewDidAppear");
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated{
    OB_INFO(@"TBMHomeViewController: view will appear");
    if (self.videoRecorder != nil)
        [self.videoRecorder dispose];
}

- (void) didReceiveMemoryWarning{
    OB_ERROR(@"TBMHomeViewController: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) setupVideoPlayers{
    [TBMVideoPlayer removeAll];
    for (TBMFriend *friend in [TBMFriend all]){
        UIView *playerView = [self friendViewWithViewIndex:friend.viewIndex];
        [TBMVideoPlayer createWithView:playerView friendId:friend.idTbm];
    }
}

- (void)setupFriendViews{
    for (TBMFriend *friend in [TBMFriend all]){
        [self updateFriendLabelWithFriendOnMainThread:friend];
    }
}

- (void)updateFriendLabelWithFriendOnMainThread:(TBMFriend *)friend{
    [self performSelectorOnMainThread:@selector(updateFriendLabelWithFriend:) withObject:friend waitUntilDone:YES];
}

- (void)updateFriendLabelWithFriend:(TBMFriend *)friend{
    UILabel *label = [self friendLabelWithViewIndex:friend.viewIndex];
    label.text = [friend videoStatusString];
    [self.view setNeedsDisplay];
}

- (void)setupLongPressTouchHandler{
    _longPressTouchHandler = [[TBMLongPressTouchHandler alloc] initWithTargetViews:[self activeFriendViews] instantiator:self];
}

- (NSMutableArray *)activeFriendViews{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TBMFriend *friend in [TBMFriend all]){
        [result addObject:[self friendViewWithViewIndex:friend.viewIndex]];
    }
    return result;
}

- (UIView *)friendViewWithViewIndex:(NSNumber *)viewIndex{
    if (!viewIndex)
        return nil;
    
    NSInteger tag = [viewIndex integerValue];
    tag += TBM_HOME_FRIEND_VIEW_INDEX_OFFSET;
    for (UIView *view in self.friendViews) {
        if (view.tag == tag){
            return view;
        }
    }
    return nil;
}

- (UILabel *)friendLabelWithViewIndex:(NSNumber *)viewIndex{
    NSInteger tag = [viewIndex integerValue];
    tag += TBM_HOME_FRIEND_LABEL_INDEX_OFFSET;
    for (UILabel *label in self.friendLabels){
        if (label.tag == tag){
            return label;
        }
    }
    return nil;
}

- (TBMFriend *)friendWithViewTag:(NSUInteger)tag{
    return [TBMFriend findWithViewIndex:@(tag-TBM_HOME_FRIEND_VIEW_INDEX_OFFSET)];
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
    [self setupVideoRecorder:videoRecorderRetryCount];
}

- (void)setupVideoRecorder:(int)retryCount{
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
    TBMFriend *friend = (TBMFriend *)object;
    [self updateFriendLabelWithFriendOnMainThread:friend];
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
    TBMFriend *friend = [self friendWithViewTag:view.tag];
    TBMVideoPlayer * player = [TBMVideoPlayer findWithFriendId:friend.idTbm];
    // DebugLog(@"TBMHomeViewController: LPTH: click on %@ calling toggle with player: %@", friend.firstName, player);
    [player togglePlay];
}

- (void)LPTHStartLongPressWithTargetView:(UIView *)view{
    // DebugLog(@"TBMHomeViewController: LPTH: startLongPress %ld", (long)view.tag);
    TBMFriend *friend = [self friendWithViewTag:view.tag];
    [[self videoRecorder] startRecordingWithMarker:friend.idTbm];
    [self showRecordingIndicator];
}

- (void)LPTHEndLongPressWithTargetView:(UIView *)view{
    // DebugLog(@"TBMHomeViewController: LPTH:  endLongPressed %ld", (long)view.tag);
    [[self videoRecorder] stopRecording];
    [self hideRecordingIndicator];
}

- (void)LPTHCancelLongPressWithTargetView:(UIView *)view{
    // DebugLog(@"TBMHomeViewController: LPTH:  cancelLongPress %ld", (long)view.tag);
    [[self videoRecorder] cancelRecording];
    [self hideRecordingIndicator];
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
