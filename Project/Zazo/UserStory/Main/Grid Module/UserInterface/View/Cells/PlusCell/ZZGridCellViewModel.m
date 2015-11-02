//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZGridCellViewModel.h"
#import "ZZVideoPlayer.h"
#import "NSObject+ANSafeValues.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoRecorder.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoStatuses.h"
#import "ZZStoredSettingsManager.h"
#import "TBMFriend.h"
#import "ZZFriendDataProvider.h"
#import "iToast.h"
#import "ZZGridActionStoredSettings.h"

@interface ZZGridCellViewModel ()

@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;
@property (nonatomic, assign) CGPoint initialRecordPoint;

@end

@implementation ZZGridCellViewModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)setUsernameLabel:(UILabel *)usernameLabel
{
    _usernameLabel = usernameLabel;
    ANDispatchBlockToMainQueue(^{
       _usernameLabel.text = [self videoStatusString];
    });
}

- (NSString*)videoStatusString
{
    ZZFriendDomainModel* friendModel = self.item.relatedUser;
    TBMFriend* friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
    
    if ([ZZStoredSettingsManager shared].debugModeEnabled)
    {
        return friendEntity.videoStatusString;
    }
    else
    {
        return friendEntity.displayName;
    }
}

- (void)itemSelected
{
    if (![self.delegate isGridRotate])
    {
        [self.delegate addUserToItem:self];
    }
}

- (void)reloadDebugVideoStatus
{
    ANDispatchBlockToMainQueue(^{
       self.usernameLabel.text = [self videoStatusString];
    });
}


- (void)updateRecordingStateTo:(BOOL)isRecording
           withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    [self.delegate recordingStateUpdatedToState:isRecording viewModel:self withCompletionBlock:completionBlock];
    [self reloadDebugVideoStatus];
}

- (ZZGridCellViewModelState)state
{
    ZZGridCellViewModelState modelState = ZZGridCellViewModelStateNone;
    
    if (!self.item.relatedUser)
    {
        modelState = ZZGridCellViewModelStateAdd;
    }
    else if ((self.item.relatedUser.hasApp && self.hasDownloadedVideo) ||
             self.item.relatedUser.videos.count > 0)
    {
        modelState = ZZGridCellViewModelStatePreview;
    }
    else if (self.item.relatedUser.hasApp)
    {
        modelState = ZZGridCellViewModelStateFriendHasApp;
    }
    else if (!ANIsEmpty(self.item.relatedUser) && !self.item.relatedUser.hasApp)
    {
        modelState = ZZGridCellViewModelStateFriendHasNoApp;
    }
    
    
    modelState = [self _additionalModelStateWithState:modelState];
    
    
    return modelState;
}

- (ZZGridCellViewModelState)_additionalModelStateWithState:(ZZGridCellViewModelState)state
{
    ZZGridCellViewModelState stateWithAdditionalState = state;
    
    if (self.hasUploadedVideo &&
        !self.isUploadedVideoViewed &&
        self.item.relatedUser.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasUploaded);
    }
    else if (self.isUploadedVideoViewed &&
        self.item.relatedUser.lastVideoStatusEventType != INCOMING_VIDEO_STATUS_EVENT_TYPE)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasViewed);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading &&
             self.item.relatedUser.unviewedCount > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloading);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded &&
             !self.item.isDownloadAnimationViewed)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloaded);
    }
    
    // green border state
    if ([self.badgeNumber integerValue] > 0
             && self.item.relatedUser.lastIncomingVideoStatus != ZZVideoIncomingStatusDownloading)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateNeedToShowGreenBorder);
    }
    
    // badge state
    if ([self.badgeNumber integerValue] == 1
        && self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne);
    }
    else if ([self.badgeNumber integerValue] > 1)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoCountMoreThatOne);
    }
    
    return stateWithAdditionalState;
}


- (void)updateVideoPlayingStateTo:(BOOL)isPlaying
{
//    if (isPlaying)
//    {
//        self.prevBadgeNumber = nil;
//        self.badgeNumber = nil;
//    }

    [self.delegate playingStateUpdatedToState:isPlaying viewModel:self];
    [self reloadDebugVideoStatus];
}

- (void)nudgeSelected
{
    if (![self.delegate isGridRotate])
    {
        [self reloadDebugVideoStatus];
        [self.delegate nudgeSelectedWithUserModel:self.item.relatedUser];
    }
}

- (void)togglePlayer
{
    [self.videoPlayer toggle];
    self.usernameLabel.text = [self videoStatusString];
}

- (NSString*)firstName
{
    return [NSObject an_safeString:self.item.relatedUser.firstName];
}

- (NSArray*)playerVideoURLs
{
    return self.item.relatedUser.videos;
}

- (UIImage*)thumbSnapshot
{
    return [self _videoThumbnail];
}


#pragma mark - Video Thumbnail

- (UIImage *)videoThumbnailImage
{
    return [self _videoThumbnail];
}

- (UIImage*)thumbnailPlaceholderImage
{
    CGSize size = CGSizeMake(40, 40);
    UIImage* image = [[UIImage imageWithPDFNamed:@"contacts-placeholder" atSize:size]
                      an_imageByTintingWithColor:[ZZColorTheme shared].gridStatusViewThumnailZColor];
    return image;
}

- (void)setBadgeNumber:(NSNumber *)badgeNumber
{
    _badgeNumber = badgeNumber;
}


- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellVeiwModelAnimationDelegate>)animationDelegate
{
    self.animationDelegate = animationDelegate;
    [self _removeLongPressRecognizerFromView:view];
    [view addGestureRecognizer:self.recordRecognizer];
}

- (void)_removeLongPressRecognizerFromView:(UIView*)view
{
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull recognizer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        {
            [view removeGestureRecognizer:recognizer];
        }
    }];
}

- (UILongPressGestureRecognizer *)recordRecognizer
{
    if (!_recordRecognizer)
    {
        _recordRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_recordPressed:)];
        _recordRecognizer.minimumPressDuration = 0.2;
    }
    return _recordRecognizer;
}



#pragma mark - Private



#pragma mark  - Recording recognizer handle

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    
    if (![self.delegate isGridRotate])
    {
        [self _checkIsCancelRecordingWithRecognizer:recognizer];
        
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            self.initialRecordPoint = [recognizer locationInView:recognizer.view];
            
            [self updateRecordingStateTo:YES withCompletionBlock:^(BOOL isRecordingSuccess) {
                if (isRecordingSuccess)
                {
                    self.hasUploadedVideo = YES;
                    [self.animationDelegate showUploadAnimation];
                    self.usernameLabel.text = [self videoStatusString];
                }
            }];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            self.initialRecordPoint = CGPointZero;
            [self _stopVideoRecording];
        }
    }

}

- (void)_stopVideoRecording
{
    [self updateRecordingStateTo:NO withCompletionBlock:^(BOOL isRecordingSuccess) {
        if (isRecordingSuccess)
        {
            self.hasUploadedVideo = YES;
            [self.animationDelegate showUploadAnimation];
            self.usernameLabel.text = [self videoStatusString];
        }
    }];
}

- (void)_checkIsCancelRecordingWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    
    if ([ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        
        
        CGFloat addTouchBounds = 80;
        if (IS_IPAD)
        {
            addTouchBounds *= 2;
        }
        
        UIView* recordView = recognizer.view;
        
        CGPoint location = [recognizer locationInView:recordView];
        
        CGRect observeFrame = CGRectMake(self.initialRecordPoint.x - addTouchBounds,
                                         self.initialRecordPoint.y - addTouchBounds,
                                         (addTouchBounds * 2),
                                         (addTouchBounds * 2));
        
        if (!CGRectContainsPoint(observeFrame,location))
        {
            [[ZZVideoRecorder shared] cancelRecordingWithReason:NSLocalizedString(@"record-dragged-finger-away", nil)];
        }
    }
}


- (NSString*)videoStatus
{
    NSInteger status = self.item.relatedUser.lastIncomingVideoStatus;
    return ZZVideoIncomingStatusShortStringFromEnumValue(status);
}


#pragma mark - Generate Thumbnail

- (UIImage*)_videoThumbnail
{
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray* sortedVideoArray = [self.item.relatedUser.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    ZZVideoDomainModel* lastModel = [sortedVideoArray lastObject];
    
    [ZZThumbnailGenerator generateThumbVideo:lastModel];
    
    return [ZZThumbnailGenerator lastThumbImageForUser:self.item.relatedUser];
}


#pragma mark  - Video Play Validation

- (BOOL)isEnablePlayingVideo
{
    BOOL isEnbaled = YES;
    
    if ((self.item.relatedUser.unviewedCount == 1) &&
        self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        isEnbaled = NO;
        [self _showMessage:NSLocalizedString(@"video-playing-disabled-reason-downloading", nil)];
    }
    
    return isEnbaled;
}

- (BOOL)isVideoPlayed
{
    return [self.delegate isVideoPlaying];;
}

- (void)_showMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}

@end
