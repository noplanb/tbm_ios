//
//  TBMGridElementViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 12/9/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridElementViewController.h"
#import "HexColor.h"
#import "TBMGridElement.h"
#import "TBMVideo.h"

@interface TBMGridElementViewController()
@property NSInteger index;
@property TBMGridElement *gridElement;

@property UIView *noThumbNoAppView;
@property UIView *noThumbHasAppView;
@property UIView *noFriendView;
@property UILabel *nameLabel;
@property NSArray *greenBorder;
@property UILabel *countLabel;
@property UIImageView *thumbView;
@property UIView *uploadingIndicator;
@property UIView *downloadingIndicator;
@property UIView *viewedIndicator;

@property TBMVideoPlayer *videoPlayer;
@end

@implementation TBMGridElementViewController

- (instancetype)initWithIndex:(NSInteger)index{
    self = [super init];
    if (self != nil){
        _index = index;
        _videoPlayer = [TBMVideoPlayer sharedInstance];
        _gridElement = [TBMGridElement findWithIndex:index];
    }
    return self;
}

static const float LayoutConstNameLabelHeight = 22;
static const float LayoutConstNameLabelFontSize = 0.55 * LayoutConstNameLabelHeight;
static const float LayoutConstBorderWidth = 3;
static const float LayoutConstCountWidth = 22;
static const float LayoutConstUnviewedCountFontSize = 0.5 * LayoutConstCountWidth;
static const float LayoutConstIndicatorBoxWidth = LayoutConstNameLabelHeight;
static const float LayoutConstIndicatorWidth = LayoutConstIndicatorBoxWidth - 7;
static const float LayoutConstNoThumbButtonsMargin = 2;
static const float LayoutConstNoThumbFontSize = 15;

static NSString *LayoutConstOrangeColor = @"F48A31";
static NSString *LayoutConstGreenColor = @"9BC046";
static NSString *LayoutConstWhiteTextColor  = @"ccc";
static NSString *LayoutConstLabelGreyColor = @"4E4D42";
static NSString *LayoutConstRedColor = @"D90D19";
static NSString *LayoutConstBlackButtonColor = @"1C1C19";

- (void)viewWillAppear:(BOOL)animated{
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
        [self updateView];
}

- (void)gridDidChange:(NSInteger)index{
    if (index == self.index)
        [self updateView];
}

- (void)videoPlayerStateDidChangeWithIndex:(NSInteger)index view:(UIView *)view isPlaying:(BOOL)isPlaying{
    // Upldate all views ignoring index becuase user may click a view while another one is playing.
    // Video player may not send the stop event for the first one in that case. So just update all views
    // to make sure everything is correct.
    [self updateView];
}


//------------------
// Building the view
//------------------
- (void)buildView{
    self.view.backgroundColor = [UIColor colorWithHexString:LayoutConstOrangeColor alpha:1];
    [self addPlus];
    [self addNoThumbNoApp];
    [self addNoTHumbHasApp];
    [self addThumb];
    [self addNameLabel];
    [self addGreenBorder];
    [self addCountLabel];
    [self showGreenBorder];
    [self addUploadingIndicator];
    [self addDownloadingIndicator];
    [self addViewedIndicator];
}

- (void) addNoThumbNoApp{
    float availH = (self.view.frame.size.height - LayoutConstNameLabelHeight);
    float h = (availH - 3*LayoutConstNoThumbButtonsMargin) / 2;
    float w = (self.view.frame.size.width - 2*LayoutConstNoThumbButtonsMargin);
    UILabel *nudge = [self noThumbLabel:CGRectMake(LayoutConstNoThumbButtonsMargin, LayoutConstNoThumbButtonsMargin, w, h)];
    nudge.textColor = [UIColor colorWithHexString:LayoutConstOrangeColor];
    nudge.text = @"Nudge";
    
    float y = 2 * LayoutConstNoThumbButtonsMargin + h;
    UILabel *record = [self noThumbLabel:CGRectMake(LayoutConstNoThumbButtonsMargin, y, w, h)];
    record.textColor = [UIColor colorWithHexString:LayoutConstRedColor];
    record.text = @"Record";
    
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
    record.text = @"Record";
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

- (void)addPlus{
    UIImage *plusImg = [UIImage imageNamed:@"plus"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:plusImg];
    float w = self.view.frame.size.width / 2;
    w = fminf(w, plusImg.size.width);
    float x = (self.view.frame.size.width - w) / 2;
    float y = (self.view.frame.size.height -w) / 2;
    iv.frame = CGRectMake(x, y, w, w);
    self.noFriendView = [[UIView alloc] initWithFrame:self.view.frame];
    self.noFriendView.backgroundColor = [UIColor colorWithHexString:LayoutConstOrangeColor];
    [self.noFriendView addSubview:iv];
    [self.view addSubview:self.noFriendView];
}

- (void)addNameLabel{
    float y = self.view.bounds.size.height - LayoutConstNameLabelHeight;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, LayoutConstNameLabelHeight)];
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstLabelGreyColor alpha:1];
    self.nameLabel.textColor = [UIColor colorWithHexString:LayoutConstWhiteTextColor alpha:1];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:LayoutConstNameLabelFontSize];
    self.nameLabel.text = @"Stephanie";
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
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.text = @"1";
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
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uploadingIcon"]];
    self.uploadingIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.uploadingIndicator];
}

- (void)addDownloadingIndicator{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downloadingIcon"]];
    self.downloadingIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.downloadingIndicator];
}

- (void)addViewedIndicator{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewedIcon"]];
    self.viewedIndicator = [self createIndicatorWithImage:iv];
    [self.view addSubview:self.viewedIndicator];
}

- (UIView *)createIndicatorWithImage:(UIImageView *)iv{
    float aspect = iv.frame.size.width / iv.frame.size.height;
    CGSize ivSize = CGSizeMake(LayoutConstIndicatorWidth, LayoutConstIndicatorWidth / aspect);
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LayoutConstIndicatorBoxWidth, LayoutConstIndicatorBoxWidth)];
    v.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor];
    float x = (v.frame.size.width - ivSize.width) / 2;
    float y = (v.frame.size.height - ivSize.height) / 2;
    iv.frame = CGRectMake(x, y, ivSize.width, ivSize.height);
    [v addSubview:iv];
    return v;
}

//-------------
// View actions
//-------------
// All
- (void)hideAll{
    [self hideAllIcons];
    [self hideAllContent];
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
    self.downloadingIndicator.hidden = NO;
}
- (void)hideDownload{ self.downloadingIndicator.hidden = YES; }

- (void)showUpload{
    [self hideAllIcons];
    self.uploadingIndicator.hidden = NO;
}
- (void)hideUpload { self.uploadingIndicator.hidden = YES; }

- (void)showViewed{
    [self hideAllIcons];
    self.viewedIndicator.hidden = NO;
}
- (void)hideViewed{ self.viewedIndicator.hidden = YES; }


// Name Label
- (void)updateNameLabel{
    self.nameLabel.text = [self.gridElement.friend videoStatusString];
}
- (void)showNameLabel{
    self.nameLabel.hidden = NO;
}
- (void)makeNameLabelGreen{
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstGreenColor];
    self.nameLabel.textColor = [UIColor whiteColor];
}
- (void)makeNameLabelGrey{
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:LayoutConstLabelGreyColor];
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
    if ([self.videoPlayer isPlayingWithIndex:self.index]){
        [self hideUnviewed];
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
        return;
    }
    
    if (!self.gridElement.friend.hasThumb && self.gridElement.friend.hasApp){
        [self showNoThumbHasApp];
        return;
    }
    
    [self showThumb];
    
    if ([self.gridElement.friend incomingVideoNotViewed]){
        [self showUnviewed];
        return;
    }
    
    if (self.gridElement.friend.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE){
        switch (self.gridElement.friend.lastIncomingVideoStatus) {
            case INCOMING_VIDEO_STATUS_NEW:
            case INCOMING_VIDEO_STATUS_DOWNLOADING:
                [self showDownload];
                return;
                
            case INCOMING_VIDEO_STATUS_DOWNLOADED:
            case INCOMING_VIDEO_STATUS_VIEWED:
            case INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY:
            default:
                return;
        }
    }
    
    if (self.gridElement.friend.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE){
        switch (self.gridElement.friend.outgoingVideoStatus) {
            case OUTGOING_VIDEO_STATUS_NEW:
            case OUTGOING_VIDEO_STATUS_QUEUED:
            case OUTGOING_VIDEO_STATUS_UPLOADING:
            case OUTGOING_VIDEO_STATUS_UPLOADED:
            case OUTGOING_VIDEO_STATUS_DOWNLOADED:
                [self showUpload];
                return;
                
            case OUTGOING_VIDEO_STATUS_VIEWED:
                [self showViewed];
                return;
                
            case OUTGOING_VIDEO_STATUS_NONE:
            case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
            default:
                return;
        }
    }
}
@end