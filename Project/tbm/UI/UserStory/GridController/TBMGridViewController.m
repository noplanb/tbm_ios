//
//  TBMGridViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 12/10/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController+Invite.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMGridElementViewController.h"
#import "TBMGridElement.h"
#import "HexColors.h"
#import "iToast.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoProcessor.h"
#import "TBMAlertController.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "MagicalRecord.h"

@interface TBMGridViewController ()
@property(nonatomic) NSArray *gridViews;
@property(nonatomic) TBMLongPressTouchHandler *longPressTouchHandler;
@property(nonatomic) TBMAppDelegate *appDelegate;
@property(nonatomic) TBMVideoRecorder *videoRecorder;
@property(nonatomic, strong) TBMGridElement *lastAddedGridElement;
@property(nonatomic, strong) TBMFriend *lastAddedFriend;
@property(nonatomic) NSUInteger lastViewedMessageGridIndex;
@end

@interface TBMGridViewController ()
@end

@implementation TBMGridViewController

//----------
// Lifecycle
//----------
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _appDelegate = (TBMAppDelegate *) [[UIApplication sharedApplication] delegate];
        [self registerAsAppEventsDelegate];
        [self setupGridElement];

    }
    return self;
}


- (void)viewDidLoad {
    //fix
    self.view.frame = self.frame;
    //---
    [self addViews];
    [self setupLongPressTouchHandler];
    [[TBMVideoPlayer sharedInstance].playerView removeFromSuperview];
    [self.view addSubview:[TBMVideoPlayer sharedInstance].playerView];
    [self setupCenterGestures];
    [TBMFriend addVideoStatusNotificationDelegate:self];
    [self addObservers];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.delegate gridDidAppear:self];
    [self setupVideoRecorder:0];
}

- (void)dealloc {
    [self removeObservers];
    // Eliminated videoRecorder.dispose here. The OS takes care of interrupting or stopping and restarting our VideoCaptureSession very well.
    // We don't need to interfere with it.

};

//--------------------------------
// Events called in by appDelegate
//--------------------------------
- (void)registerAsAppEventsDelegate {
    [self.appDelegate setLifeCycleEventNotificationDelegate:self];
}

- (void)appDidBecomeActive {
    if ([self isViewLoaded] && self.view.window) {
        // viewController is visible
        OB_INFO(@"appDidBecomeActive: calling setupVideoRecorder:0");
        [self setupVideoRecorder:0];
    } else {
        OB_WARN(@"appDidBecomeActive: not setting up VideoRecorder because !self.isViewLoaded && self.view.window");
    }
}

- (void)appWillEnterForeground {
}


//---------------------------
// Events called in by Friend
//---------------------------
#pragma mark Events from friend

- (void)videoStatusDidChange:(TBMFriend *)friend {
    if (![TBMGridElement friendIsOnGrid:friend])
        [self moveFriendToGrid:friend];
}

#pragma mark - Notification Center Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoRecordDidFailNotification:)
                                                 name:TBMVideoProcessorDidFail
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoRecordDidFailNotification:)
                                                 name:TBMVideoRecorderDidFail
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TBMVideoProcessorDidFail
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TBMVideoRecorderDidFail
                                                  object:nil];

}

- (void)videoRecordDidFailNotification:(NSNotification *)notification {
    NSError *error = (NSError *) notification.userInfo[@"error"];
    NSString *reason = error.userInfo[NSLocalizedFailureReasonErrorKey];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (reason != nil)
            [[iToast makeText:reason] show];

        [self performSelector:@selector(toastNotSent) withObject:nil afterDelay:1.2];
    });
}

#pragma mark - GridElement Setup

- (void)setupGridElement {
    if ([TBMGridElement all].count != 8) {
        [self createGridElements];
    }
}

- (void)createGridElements
{
    NSManagedObjectContext* context = [NSManagedObjectContext MR_context];
    [TBMGridElement destroyAllOncontext:context];
    
    NSArray *friends = [TBMFriend MR_findAllInContext:context];
    
    for (NSInteger i = 0; i < 8; i++)
    {
        TBMGridElement *ge = [TBMGridElement createInContext:context];
        ge.index = @(i);
        if (i < friends.count)
        {
            TBMFriend *aFriend = friends[i];
            ge.friend = aFriend;
        }
    }
    [context MR_saveToPersistentStoreAndWait];
}


//==================================
// Adding the views for the nineGrid
//==================================
static const float LayoutConstGUTTER = 8;
static const float LayoutConstMARGIN = 5;
static const float LayoutConstASPECT = 0.75;

- (void)addViews {
    [self addNineGrid];
    [self addChildViewControllers];
}


- (void)addNineGrid {
    CGSize elSize = [self elementSize];
    float x;
    float y;
    UIView *v;
    NSMutableArray *gvs = [[NSMutableArray alloc] init];
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            x = [self LayoutConstGUTTERLeft] + col * (LayoutConstMARGIN + elSize.width);
            y = [self gridTop] + row * (LayoutConstMARGIN + elSize.height);
            if (row == col == 1) {
                v = [[TBMPreviewView alloc] initWithFrame:CGRectMake(x, y, elSize.width, elSize.height)];
            } else {
                v = [[UIView alloc] initWithFrame:CGRectMake(x, y, elSize.width, elSize.height)];
            }
            [self.view addSubview:v];
            [gvs addObject:v];
        }
    }
    [self setGridViews:gvs];
}

- (void)addChildViewControllers {
    CGSize elSize = [self elementSize];
    NSInteger i = 0;
    for (UIView *v in [self outsideViews]) {
        CGRect frame = CGRectMake(0, 0, elSize.width, elSize.height);
        TBMGridElementViewController *c = [[TBMGridElementViewController alloc] initWithIndex:i frame:frame];
        c.gridElementDelegate = self;
        [self addChildViewController:c];

        [v addSubview:c.view];
        i++;
    }
}

- (CGSize)elementSize {
    CGFloat mainViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat mainViewHeight = CGRectGetHeight(self.view.bounds);
    CGFloat width;
    CGFloat height;
    if ([self isHeightConstrained]) {
        height = (mainViewHeight - 2 * (LayoutConstGUTTER + LayoutConstMARGIN)) / 3;
        width = LayoutConstASPECT * height;
    } else {
        width = (mainViewWidth - 2 * (LayoutConstGUTTER + LayoutConstMARGIN)) / 3;
        height = width / LayoutConstASPECT;
    }
    return CGSizeMake(width, height);
}

- (float)gridTop {
    if ([self isHeightConstrained]) {
        return LayoutConstGUTTER;
    } else {
        CGFloat elementHeight = [self elementSize].height;
        return  (CGRectGetHeight(self.view.bounds) - 3 * elementHeight - 2 * LayoutConstMARGIN) / 2;;
    }
}

- (float)LayoutConstGUTTERLeft {
    if ([self isWidthConstrained])
        return LayoutConstGUTTER;
    else {
        CGFloat elementWidth = [self elementSize].width;
        return (CGRectGetWidth(self.view.bounds) - 3 * elementWidth - 2 * LayoutConstMARGIN) / 2;
    }
}

- (BOOL)isWidthConstrained {
    return (self.view.bounds.size.width / self.view.bounds.size.height) < LayoutConstASPECT;
}

- (BOOL)isHeightConstrained {
    return ![self isWidthConstrained];
}

//------------------------------------------
// Longpress touch handling for outside views
//------------------------------------------
- (void)setupLongPressTouchHandler {
    // DebugLog(@"setupLongPressTouchHandler %@", [self outsideViews]);
    self.longPressTouchHandler = [[TBMLongPressTouchHandler alloc] initWithTargetViews:[self outsideViews] instantiator:self];
}

// We detect the touches for the entire view using this view controller but pass them to the longPressTouchHandler.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesCancelled:touches withEvent:event];
    }
}

// Callbacks per the TBMLongPressTouchHandlerCallback protocol.
- (void)LPTHClickWithTargetView:(UIView *)view {
    if ([TBMBenchViewController existingInstance].isShowing)
        return;

    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil) {
        [self rankingActionOccurred:ge.friend];
        [[TBMVideoPlayer sharedInstance] togglePlayWithIndex:[self indexWithView:view] frame:view.frame];
    }
}

- (void)LPTHStartLongPressWithTargetView:(UIView *)view {
    if ([TBMBenchViewController existingInstance].isShowing)
        return;

    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil) {
        [self rankingActionOccurred:ge.friend];
        [[TBMVideoPlayer sharedInstance] stop];
        NSURL *videoUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriend:ge.friend];
        [[self videoRecorder] startRecordingWithVideoUrl:videoUrl];
    }
}

- (void)LPTHEndLongPressWithTargetView:(UIView *)view {
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil) {
        [[self videoRecorder] stopRecording];
    }
}

- (void)LPTHCancelLongPressWithTargetView:(UIView *)view reason:(NSString *)reason {
    TBMGridElement *ge = [self gridElementWithView:view];
    if (ge.friend != nil) {
        if ([[self videoRecorder] cancelRecording]) {
            [[iToast makeText:reason] show];
            [self performSelector:@selector(toastNotSent) withObject:nil afterDelay:1.2];
        }
    }
}

- (void)toastNotSent {
    [[iToast makeText:@"Not sent"] show];
}


//---------------------------------
// Gesture handling for center view
//---------------------------------
- (void)setupCenterGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showCenterHint:)];
    [[self centerView] addGestureRecognizer:tap];
}

- (void)showCenterHint:(UITapGestureRecognizer *)sender {
    if ([TBMFriend count] == 0)
        return;

    NSString *msg;
    if ([TBMVideo downloadedUnviewedCount] > 0)
        msg = @"Tap a friend to play.";
    else
        msg = @"Press and hold a friend to record.";

    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Hint" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}


//--------------------------------
// View to grid element conversion
//--------------------------------
- (NSArray *)outsideViews {
    if ([self gridViews] == nil)
        return nil;
    return @[[self gridViews][5],
            [self gridViews][7],
            [self gridViews][8],
            [self gridViews][6],
            [self gridViews][2],
            [self gridViews][3],
            [self gridViews][1],
            [self gridViews][0]];
}

- (TBMPreviewView *)centerView {
    if ([self gridViews] == nil)
        return nil;
    return [self gridViews][4];
}

- (NSInteger)indexWithView:(UIView *)view {
    return [self.outsideViews indexOfObject:view];
}

- (TBMGridElement *)gridElementWithView:(UIView *)view {
    return [TBMGridElement findWithIntIndex:[self indexWithView:view]];
}

- (UIView *)gridViewWithIndex:(NSUInteger)index {
    return self.outsideViews[index];
}


//-------------------------
// Handling friends on grid
//-------------------------
- (NSMutableArray *)friendsOnGrid {
    NSMutableArray *r = [[NSMutableArray alloc] init];
    for (TBMGridElement *ge in [TBMGridElement all]) {
        if (ge.friend != nil) {
            [r addObject:ge.friend];
        }
    }
    return r;
}

- (NSMutableArray *)friendsOnBench {
    NSMutableArray *allFriends = [[NSMutableArray alloc] initWithArray:[TBMFriend all]];
    NSMutableArray *gridFriends = [self friendsOnGrid];
    for (TBMFriend *gf in gridFriends) {
        [allFriends removeObject:gf];
    }
    [allFriends sortUsingComparator:^NSComparisonResult(TBMFriend *obj1, TBMFriend *obj2) {
        return [obj1.firstName caseInsensitiveCompare:obj2.firstName];
    }];
    return allFriends;
}

- (void)moveFriendToGrid:(TBMFriend *)friend {
    OB_INFO(@"moveFriendToGrid: %@", friend.firstName);
    [self rankingActionOccurred:friend];
    self.lastAddedFriend = friend;
    if ([TBMGridElement friendIsOnGrid:friend]) {
        [self highlightElement:[TBMGridElement findWithFriend:friend]];
        return;
    }

    TBMGridElement *ge = [self nextAvailableGridElement];
    self.lastAddedGridElement = ge;
    ge.friend = friend;
    [self notifyChildrenOfGridChange:[ge getIntIndex]];
    [self highlightElement:ge];

    if (ge.friend.hasApp)
    {
        [self.delegate friendDidAdd];
    } else
    {
        [self.delegate friendDidAddWithoutApp];
    }

}

- (void)notifyChildrenOfGridChange:(NSInteger)index {
    for (TBMGridElementViewController *c in self.childViewControllers) {
        [c gridDidChange:index];
    }
}


//--------
// Ranking
//--------

- (void)rankingActionOccurred:(TBMFriend *)friend {
    friend.timeOfLastAction = [NSDate date];
}

- (NSArray *)rankedFriendsOnGrid {
    return [[self friendsOnGrid] sortedArrayUsingComparator:^NSComparisonResult(TBMFriend *a, TBMFriend *b) {
        return [a.timeOfLastAction compare:b.timeOfLastAction];
    }];
}

- (TBMFriend *)lowestRankedFriendOnGrid {
    return self.rankedFriendsOnGrid[0];
}

- (TBMGridElement *)nextAvailableGridElement {
    TBMGridElement *ge = [TBMGridElement firstEmptyGridElement];

    if (ge != nil)
        return ge;

    return [TBMGridElement findWithFriend:[self lowestRankedFriendOnGrid]];
}


//---------------------------
// Highlighting a gridElement
//---------------------------
- (void)highlightElement:(TBMGridElement *)ge {
    UIView *gv = [self gridViewWithIndex:[ge getIntIndex]];
    CGRect r;
    r.size.width = gv.frame.size.width;
    r.size.height = gv.frame.size.height;
    r.origin.x = 0;
    r.origin.y = 0;
    UIView *blaze = [[UIView alloc] initWithFrame:r];
    [blaze setBackgroundColor:[UIColor colorWithHexString:@"FBD330" alpha:1]];
    [blaze setAlpha:0];
    [gv addSubview:blaze];
    [gv setNeedsDisplay];
    [self performSelector:@selector(animateBlaze:) withObject:blaze afterDelay:0.3];

}

- (void)animateBlaze:(UIView *)blaze {
    [UIView animateWithDuration:0.3 animations:^{
        [blaze setAlpha:1];
    }                completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [blaze setAlpha:0];
        }                completion:^(BOOL finished1) {
            [blaze removeFromSuperview];
        }];
    }];
}


//-----------------------------------
// VideoRecorder setup and callbacks
//-----------------------------------
- (void)videoRecorderDidStartRunning {
}

- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount {
    OB_ERROR(@"videoRecorderRuntimeErrorWithRetryCount %d", videoRecorderRetryCount);
    [self setupVideoRecorder:videoRecorderRetryCount];
}

// We call setupVideoRecorder on multiple events so the first qualifying event takes effect. All later events are ignored.
- (void)setupVideoRecorder:(int)retryCount {
    // Note that when we get retryCount != 0 we are being called because of a videoRecorderRuntimeError and we need reinstantiate
    // even if videoRecorder != nil
    // Also if we still have a videoRecorder but the OS killed our view from under us trying to save memory while we were in the
    // background we want to reinstantiate.
    if (self.videoRecorder != nil && retryCount == 0 && [self isViewLoaded] && self.view.window) {
        OB_WARN(@"TBMHomeViewController: setupVideoRecorder: already setup. Ignoring");
    }
    else if (![self appDelegate].isForeground) {
        OB_WARN(@"HomeViewController: not initializing the VideoRecorder because ! isForeground");
    }
    else {
        OB_WARN(@"HomeviewController: setupVideoRecorder: setting up. vr=%@, rc=%d, isViewLoaded=%d, view.window=%d", self.videoRecorder, retryCount, [self isViewLoaded], [self isViewLoaded] && self.view.window);

        self.videoRecorder = [[TBMVideoRecorder alloc] initWithPreviewView:[self centerView] delegate:self];
    }
    [self.videoRecorder startRunning];
}

- (BOOL)isRecording {
    return [self.videoRecorder isRecording];
}

#pragma mark - TBMGridModuleInterface

- (UIView *)viewForDialog {
    return self.homeView;
}


- (CGRect)gridGetFrameForUnviewedBadgeForFriend:(NSUInteger)friendCellIndex inView:(UIView *)view {
    CGRect result = CGRectZero;

    if (friendCellIndex <= 7) {
        result = [[self gridViewWithIndex:friendCellIndex] frame];
        CGFloat x = CGRectGetMaxX(result) - LayoutConstCountWidth + 3;
        CGFloat y = CGRectGetMinY(result) - 3;
        result = CGRectMake(x, y, LayoutConstCountWidth, LayoutConstCountWidth);
    }

    result = [self.view convertRect:result toView:view];
    return result;
}

- (CGRect)gridGetCenterCellFrameInView:(UIView *)view {
    CGRect result = [[self centerView] frame];
    result = [self.view convertRect:result toView:view];
    return result;
}

- (CGRect)gridGetFrameForFriend:(NSUInteger)friendCellIndex inView:(UIView *)view {
    CGRect result = CGRectZero;
    if (friendCellIndex <= 7) {
        result = [[self gridViewWithIndex:friendCellIndex] frame];
        result = [self.view convertRect:result toView:view];
    }

    return result;
}

- (NSUInteger)lastAddedFriendOnGridIndex {
    NSUInteger result = 0;
    TBMGridElement *gridElement = self.lastAddedFriend.gridElement;
    if (gridElement) {
        result = [gridElement.index unsignedIntegerValue];
    }
    return result;
}

- (NSString *)lastAddedFriendOnGridName
{
    NSString *result = @"";
    TBMGridElement *gridElement = self.lastAddedFriend.gridElement;
    if (gridElement)
    {
        result = gridElement.friend.firstName;
    }
    return result;
}

#pragma mark - TBMGridElementDelegate

- (void)videoPlayerDidStartPlaying:(TBMVideoPlayer *)player {
    [self.delegate videoPlayerDidStartPlaying:player];

}

- (void)videoPlayerDidStopPlaying:(TBMVideoPlayer *)player {
    [self.delegate videoPlayerDidStopPlaying:player];
}

- (void)messageDidUpload {
    [self.delegate messageDidUpload];
}

- (void)messageDidViewed:(NSUInteger)gridIndex {
    self.lastViewedMessageGridIndex = gridIndex;
    [self.delegate messageDidViewed];
}

- (void)messageDidReceive {
    [self.delegate messageDidReceive];
}

@end
