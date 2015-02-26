//
//  TBMGridElementViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 12/9/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridElementViewController.h"
#import "TBMHomeViewController+Invite.h"
#import "TBMBenchViewController.h"
#import "HexColor.h"
#import "TBMGridElement.h"
#import "TBMVideo.h"
#import "TBMMarginLabel.h"
#import "TBMAlertController.h"
#import "TBMSoundEffect.h"
#import "OBLogger.h"
#import "TBMConfig.h"

@interface TBMGridElementViewController()
@property NSInteger index;
@property TBMGridElement *gridElement;

@property UIView *noThumbNoAppView;
@property UIView *noThumbHasAppView;
@property UIView *noFriendView;
@property TBMMarginLabel *nameLabel;
@property NSArray *greenBorder;
@property UILabel *countLabel;
@property UIImageView *thumbView;
@property UIView *uploadingIndicator;
@property UIView *downloadingIndicator;
@property UIView *viewedIndicator;
@property UIView *uploadingBar;
@property UIView *downloadingBar;

@property (nonatomic) TBMSoundEffect *messageDing;

@property TBMVideoPlayer *videoPlayer;
@property BOOL isPlaying;
@end

@implementation TBMGridElementViewController

- (instancetype)initWithIndex:(NSInteger)index{
    self = [super init];
    if (self != nil){
        _index = index;
        _videoPlayer = [TBMVideoPlayer sharedInstance];
        _gridElement = [TBMGridElement findWithIntIndex:index];
        _messageDing = [[TBMSoundEffect alloc] initWithSoundNamed:CONFIG_DING_SOUND];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addProximitySensorControlObserver];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self removeProximityControlObserver];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self buildView];
    [self registerForEvents];
    [self updateView];
}


//--------------------------------
// Event Registration and handling
//--------------------------------
- (void)registerForEvents{
    [TBMFriend addVideoStatusNotificationDelegate:self];
    [self.videoPlayer addEventNotificationDelegate:self];
}

- (void)videoStatusDidChange:(TBMFriend *)friend{
    if ([[self gridElement].friend isEqual:friend])
        [self animateTransitions];
}

- (void)gridDidChange:(NSInteger)index{
    if (index == self.index)
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
}

- (void)videoPlayerStartedIndex:(NSInteger)index{
    if (index == self.index){
        // Default back to no override, and enable proximity monitoring
        UIDevice *device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = YES;
        if (device.proximityMonitoringEnabled) {
            if (!device.proximityState) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            }
        }

        self.isPlaying = YES;
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
}

- (void)videoPlayerStopped{
    // Stop proximity monitoring
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;

    self.isPlaying = NO;
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
}


//------------------
// Proximity change handling
//------------------
-(void)addProximitySensorControlObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceProximityChanged:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
}

- (void)removeProximityControlObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
}

- (void)deviceProximityChanged:(NSNotification *)notification {
    UIDevice *device = [notification object];
    if (device.proximityState) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}


//------------------
// Building the view
//------------------
static const float LayoutConstNameLabelHeight = 22;
static const float LayoutConstNameLabelMargin = 5;
static const float LayoutConstNameLabelFontSize = 0.55 * LayoutConstNameLabelHeight;
static const float LayoutConstBorderWidth = 2.5;
static const float LayoutConstCountWidth = 22;
static const float LayoutConstUnviewedCountFontSize = 0.5 * LayoutConstCountWidth;
static const float LayoutConstIndicatorMaxWidth = 40;
static const float LayoutConstIndicatorFractionalWidth = 0.15;
static const float LayoutConstNoThumbButtonsMargin = 2;
static const float LayoutConstNoThumbFontSize = 15;
static const float LayoutConstUploadingBarHeight = LayoutConstNoThumbButtonsMargin;

- (float) indicatorCalculatedWidth{
    return fminf(LayoutConstIndicatorMaxWidth, LayoutConstIndicatorFractionalWidth * self.view.frame.size.width);
}

static NSString *LayoutConstOrangeColor = @"F48A31";
static NSString *LayoutConstGreenColor = @"9BC046";
static NSString *LayoutConstWhiteTextColor  = @"fff";
static NSString *LayoutConstLabelGreyColor = @"4E4D42";
static NSString *LayoutConstRedColor = @"D90D19";
static NSString *LayoutConstBlackButtonColor = @"1C1C19";

- (void)buildView{
    self.view.backgroundColor = [UIColor colorWithHexString:LayoutConstLabelGreyColor alpha:1];
    [self addNoFriend];
    [self addNoThumbNoApp];
    [self addNoTHumbHasApp];
    [self addThumb];
    [self addNameLabel];
    [self addGreenBorder];
    [self addCountLabel];
    [self addUploadingIndicator];
    [self addUploadingBar];
    [self addDownloadingIndicator];
    [self addDownloadingBar];
    [self addViewedIndicator];
}

- (void) gevTap{
    DebugLog(@"gevTap");
}

- (void) addNoThumbNoApp{
    float availH = (self.view.frame.size.height - LayoutConstNameLabelHeight);
    float h = (availH - 3*LayoutConstNoThumbButtonsMargin) / 2;
    float w = (self.view.frame.size.width - 2*LayoutConstNoThumbButtonsMargin);
    UILabel *nudge = [self noThumbLabel:CGRectMake(LayoutConstNoThumbButtonsMargin, LayoutConstNoThumbButtonsMargin, w, h)];
    nudge.textColor = [UIColor colorWithHexString:LayoutConstOrangeColor];
    nudge.text = @"NUDGE";
    [nudge addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nudgeTap)]];
    nudge.userInteractionEnabled = YES;
    
    float y = 2 * LayoutConstNoThumbButtonsMargin + h;
    UILabel *record = [self noThumbLabel:CGRectMake(LayoutConstNoThumbButtonsMargin, y, w, h)];
    record.textColor = [UIColor colorWithHexString:LayoutConstRedColor];
    record.text = @"RECORD";
    [record addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordTap)]];
    record.userInteractionEnabled = YES;

    self.noThumbNoAppView = [self noThumbContainerView];
    [self.noThumbNoAppView addSubview:nudge];
    [self.noThumbNoAppView addSubview:record];
    [self.view addSubview:self.noThumbNoAppView];
}

- (void) addNoTHumbHasApp{
    float availH = self.view.frame.size.height - LayoutConstNameLabelHeight;
    UILabel *record = [self noThumbLabel:CGRectMake(
                                                    LayoutConstNoThumbButtonsMargin,
                                                    LayoutConstNoThumbButtonsMargin,
                                                    self.view.bounds.size.width - 2*LayoutConstNoThumbButtonsMargin,
                                                    availH - 2*LayoutConstNoThumbButtonsMargin)];
    record.textColor = [UIColor colorWithHexString:LayoutConstRedColor alpha:1];
    record.text = @"RECORD";
    [record addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordTap)]];
    record.userInteractionEnabled = YES;
    self.noThumbHasAppView = [self noThumbContainerView];
    [self.noThumbHasAppView addSubview:record];
    [self.view addSubview:self.noThumbHasAppView];
}

- (UILabel *) noThumbLabel:(CGRect)frame{
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.backgroundColor = [UIColor colorWithHexString:LayoutConstBlackButtonColor];
    l.font = [UIFont boldSystemFontOfSize:LayoutConstNoThumbFontSize];
    l.textAlignment = NSTextAlignmentCenter;
    return l;
}

- (UIView *)noThumbContainerView{
    UIView *v = [[UIView alloc] initWithFrame:self.view.frame];
    v.backgroundColor = [UIColor colorWithHexString:LayoutConstLabelGreyColor];
    return v;
}

- (void)addNoFriend{
    UIImage *plusImg = [UIImage imageNamed:@"icon-plus"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:plusImg];
    float w = self.view.frame.size.width / 2;
    w = fminf(w, plusImg.size.width);
    float x = (self.view.frame.size.width - w) / 2;
    float y = (self.view.frame.size.height -w) / 2;
    iv.frame = CGRectMake(x, y, w, w);
    self.noFriendView = [[UIView alloc] initWithFrame:self.view.frame];
    self.noFriendView.backgroundColor = [UIColor colorWithHexString:LayoutConstOrangeColor];
    [self.noFriendView addSubview:iv];
    [self.noFriendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noFriendTap)]];
    [self.view addSubview:self.noFriendView];
}

- (void)addNameLabel{
    float y = self.view.bounds.size.height - LayoutConstNameLabelHeight;
    self.nameLabel = [[TBMMarginLabel alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, LayoutConstNameLabelHeight)];
    self.nameLabel.margin = LayoutConstNameLabelMargin;
    [self makeNameLabelGrey];
    self.nameLabel.textColor = [UIColor colorWithHexString:LayoutConstWhiteTextColor alpha:1];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:LayoutConstNameLabelFontSize];
    [self.view addSubview:self.nameLabel];
}


// Green Border
- (void)addGreenBorder{
    UIView *l = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LayoutConstBorderWidth, self.view.bounds.size.height)];
    UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, LayoutConstBorderWidth)];
    UIView *r = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - LayoutConstBorderWidth, 0, LayoutConstBorderWidth, self.view.bounds.size.height)];
    self.greenBorder = [[NSArray alloc] initWithObjects:l,t,r, nil];
    for (UIView *b in self.greenBorder){
        b.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor alpha:1];
        [self.view addSubview:b];
    }
}

// Unviewed count
- (void)addCountLabel{
    float x = self.view.bounds.size.width - LayoutConstCountWidth + 3;
    float y = -3;
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, LayoutConstCountWidth, LayoutConstCountWidth)];
    self.countLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstRedColor alpha:1];
    self.countLabel.font = [UIFont systemFontOfSize:LayoutConstUnviewedCountFontSize];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.layer.cornerRadius = LayoutConstNameLabelHeight / 2;
    self.countLabel.layer.masksToBounds = YES;
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.countLabel];
}

// Thumb
- (void)addThumb{
    self.thumbView = [[UIImageView alloc] init];
    self.thumbView.frame = self.view.frame;
    [self.view addSubview:self.thumbView];
}

// Uploading, downloading and viewed indicators
- (void)addUploadingIndicator{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-uploading"]];
    self.uploadingIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.uploadingIndicator];
}

- (void)addDownloadingIndicator{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-downloading"]];
    self.downloadingIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.downloadingIndicator];
}

- (void)addViewedIndicator{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-viewed"]];
    self.viewedIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.viewedIndicator];
}

- (UIView *)createIndicatorWithImage:(UIImageView *)iv{
    float aspect = iv.frame.size.width / iv.frame.size.height;
    CGSize ivSize = CGSizeMake([self indicatorCalculatedWidth], [self indicatorCalculatedWidth] / aspect);
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - ivSize.width, 0, ivSize.width, ivSize.width)];  //Always square.
    v.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor];
    float x = (v.frame.size.width - ivSize.width) / 2;
    float y = (v.frame.size.height - ivSize.height) / 2;
    iv.frame = CGRectMake(x, y, ivSize.width, ivSize.height);
    [v addSubview:iv];
    return v;
}

- (void)addUploadingBar{
    self.uploadingBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, LayoutConstUploadingBarHeight)];
    self.uploadingBar.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor];
    self.uploadingBar.hidden = YES;
    [self.view addSubview:self.uploadingBar];
}

- (void)addDownloadingBar{
    self.downloadingBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, LayoutConstUploadingBarHeight)];
    self.downloadingBar.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor];
    self.downloadingBar.hidden = YES;
    [self.view addSubview:self.downloadingBar];
}

//-------------
// View actions
//-------------
// All
- (void)hideAll{
    [self hideAllIcons];
    [self hideAllContent];
    [self hideNameLabel];
}

// Icons and borders
- (void)hideAllIcons{
    [self hideUnviewed];
    [self hideDownload];
    [self hideUpload];
    [self hideViewed];
}

- (void)showGreenBorder{
    for (UIView *b in self.greenBorder){
        b.hidden = NO;
    }
    [self makeNameLabelGreen];
    [self showNameLabel];
}

- (void)hideGreenBorder{
    for (UIView *b in self.greenBorder){
        b.hidden = YES;
    }
    [self makeNameLabelGrey];
}

- (void)updateUnviewedCount{
    if (self.gridElement.friend == nil) {
        self.countLabel.text = @"";
    } else {
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gridElement.friend.unviewedCount];
    }
}

- (void)showUnviewed{
    [self hideAllIcons];
    [self showGreenBorder];
    self.countLabel.hidden = NO;
}

- (void)hideUnviewed{
    [self hideGreenBorder];
    self.countLabel.hidden = YES;
}

- (void)showDownload{
    [self hideAllIcons];
    CGRect f = self.downloadingIndicator.frame;
    f.origin.x = self.view.frame.size.width - f.size.width;
    self.downloadingIndicator.frame = f;
    self.downloadingIndicator.hidden = NO;
}
- (void)hideDownload{
    self.downloadingIndicator.hidden = YES;
    self.downloadingBar.hidden = YES;
}

- (void)showUpload{
    [self hideAllIcons];
    self.uploadingIndicator.hidden = NO;
}
- (void)hideUpload {
    self.uploadingIndicator.hidden = YES;
}
- (void)hideUploadBar{
    self.uploadingBar.hidden = YES;
}

- (void)showViewed{
    [self hideAllIcons];
    self.viewedIndicator.hidden = NO;
}
- (void)hideViewed{ self.viewedIndicator.hidden = YES; }

// Animations
- (void)animateUploading{
    [self hideAllIcons];
    [self hideUnviewed];
    CGRect startFrame = self.uploadingIndicator.frame;
    startFrame.origin.x = 0;
    self.uploadingIndicator.frame = startFrame;
    CGRect endFrame = self.uploadingIndicator.frame;
    endFrame.origin.x = self.view.frame.size.width - self.uploadingIndicator.frame.size.width;
    [self showUpload];
    
    CGRect barStartFrame = self.uploadingBar.frame;
    barStartFrame.size.width = 0;
    CGRect barEndFrame = self.uploadingBar.frame;
    barEndFrame.size.width = self.view.frame.size.width - self.uploadingIndicator.frame.size.width;
    self.uploadingBar.frame = barStartFrame;
    self.uploadingBar.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.uploadingIndicator.frame = endFrame;
        self.uploadingBar.frame = barEndFrame;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideUploadBar) withObject:nil afterDelay:0.2];
        [self performSelector:@selector(updateView) withObject:nil afterDelay:0.4];
    }];
}

- (void)animateDownloading{
    [self hideAllIcons];
    [self hideUnviewed];
    CGRect startFrame = self.downloadingIndicator.frame;
    startFrame.origin.x = self.view.frame.size.width - self.downloadingIndicator.frame.size.width;
    self.downloadingIndicator.frame = startFrame;
    CGRect endFrame = self.downloadingIndicator.frame;
    endFrame.origin.x = 0;
    [self showDownload];
    
    CGRect barStartFrame = self.downloadingBar.frame;
    barStartFrame.size.width = 0;
    barStartFrame.origin.x = self.view.frame.size.width;
    CGRect barEndFrame = self.downloadingBar.frame;
    barEndFrame.size.width = self.view.frame.size.width - self.downloadingIndicator.frame.size.width;
    barEndFrame.origin.x = self.downloadingIndicator.frame.size.width;
    self.downloadingBar.frame = barStartFrame;
    self.downloadingBar.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.downloadingIndicator.frame = endFrame;
        self.downloadingBar.frame = barEndFrame;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(updateView) withObject:nil afterDelay:0.2];
        [self performSelector:@selector(playDing) withObject:nil afterDelay:0.4];
    }];
}


// Sound actions
- (void) playDing{
    if (![[TBMVideoPlayer sharedInstance] isPlaying] && ![(TBMGridViewController *)[self parentViewController] isRecording])
        [self.messageDing play];
}

// Name Label
- (void)updateNameLabel{
    self.nameLabel.text = [self.gridElement.friend videoStatusString];
}
- (void)showNameLabel{
    self.nameLabel.hidden = NO;
}
- (void)makeNameLabelGreen{
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor alpha:1];
    self.nameLabel.textColor = [UIColor whiteColor];
}
- (void)makeNameLabelGrey{
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstLabelGreyColor alpha:0.9];
    self.nameLabel.textColor = [UIColor colorWithHexString:LayoutConstWhiteTextColor];
}
- (void)hideNameLabel{
    self.nameLabel.hidden = YES;
}


// Content
- (void)hideAllContent{
    [self hideThumb];
    [self hideNoThumbHasApp];
    [self hideNoThumbNoApp];
    [self hideNoFriend];
}

- (void)updateThumbImage{
    NSURL *url = self.gridElement.friend.thumbUrl;
    if (url == nil)
        return;
    
    [self.thumbView setImage:[UIImage imageWithContentsOfFile:url.path]];
}
- (void)showThumb{
    [self hideAllContent];
    [self showNameLabel];
    [self makeNameLabelGrey];
    self.thumbView.hidden = NO;
}
- (void)hideThumb{ self.thumbView.hidden = YES; }

- (void)showNoThumbHasApp{
    [self hideAll];
    [self showNameLabel];
    [self makeNameLabelGrey];
    self.noThumbHasAppView.hidden = NO;
}
- (void)hideNoThumbHasApp{ self.noThumbHasAppView.hidden = YES; }

- (void)showNoThumbNoApp{
    [self hideAll];
    [self showNameLabel];
    [self makeNameLabelGrey];
    self.noThumbNoAppView.hidden = NO;}
- (void)hideNoThumbNoApp{ self.noThumbNoAppView.hidden = YES;}

- (void)showNoFriend{
    [self hideAll];
    [self hideNameLabel];
    self.noFriendView.hidden = NO;
}
- (void)hideNoFriend{ self.noFriendView.hidden = YES; }


//------------
// Update View
//------------
- (void)updateView{
    if (self.isPlaying){
        [self hideAll];
        return;
    }

    [self updateThumbImage];
    [self updateUnviewedCount];
    [self updateNameLabel];
    
    if (self.gridElement.friend == nil){
        [self showNoFriend];
        return;
    }
    
    if (!self.gridElement.friend.hasThumb && !self.gridElement.friend.hasApp){
        [self showNoThumbNoApp];
    }
    
    if (!self.gridElement.friend.hasThumb && self.gridElement.friend.hasApp){
        [self showNoThumbHasApp];
    }
    
    if (self.gridElement.friend.hasThumb){
        [self showThumb];
    }
    
    if ([self.gridElement.friend incomingVideoNotViewed]){
        [self showUnviewed];
        return;
    }
    
    if (self.gridElement.friend.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
        self.gridElement.friend.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADING){
            [self showDownload];
            return;
    }
    
    if (self.gridElement.friend.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE){
        switch (self.gridElement.friend.outgoingVideoStatus) {
                
            case OUTGOING_VIDEO_STATUS_QUEUED:
            case OUTGOING_VIDEO_STATUS_UPLOADING:
            case OUTGOING_VIDEO_STATUS_UPLOADED:
            case OUTGOING_VIDEO_STATUS_DOWNLOADED:
                [self showUpload];
                return;
                
            case OUTGOING_VIDEO_STATUS_VIEWED:
                [self showViewed];
                return;
                
            case OUTGOING_VIDEO_STATUS_NEW:
            case OUTGOING_VIDEO_STATUS_NONE:
            case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
            default:;
        }
    }
}

- (void)animateTransitions{
    if (self.gridElement.friend.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE){
        if (self.gridElement.friend.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED){
            [self animateDownloading];
            return;
        }
    }
    
    if (self.gridElement.friend.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE){
        switch (self.gridElement.friend.outgoingVideoStatus) {
            case OUTGOING_VIDEO_STATUS_NEW:
                [self animateUploading];
                return;
            
            // Dont update the view for these.
            case OUTGOING_VIDEO_STATUS_QUEUED:
            case OUTGOING_VIDEO_STATUS_UPLOADING:
            case OUTGOING_VIDEO_STATUS_UPLOADED:
            case OUTGOING_VIDEO_STATUS_DOWNLOADED:
                return;
            
            // Update the view for these
            case OUTGOING_VIDEO_STATUS_NONE:
            case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
            case OUTGOING_VIDEO_STATUS_VIEWED:
            default:;
        }
    }
    [self updateView];
}



//-----------
// Tap events
//-----------
- (void)nudgeTap{
    if ([TBMBenchViewController existingInstance].isShowing)
        return;

    [[TBMHomeViewController existingInstance] nudge:self.gridElement.friend];
}

- (void)recordTap{
    if ([TBMBenchViewController existingInstance].isShowing)
        return;
    
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Hold to Record"
                                                                     message:@"Press and hold the RECORD button to record"];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}

- (void)noFriendTap{
    [[TBMBenchViewController existingInstance] toggle];
}
@end