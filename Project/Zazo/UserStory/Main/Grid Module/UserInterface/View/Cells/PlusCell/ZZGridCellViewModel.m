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
#import "ZZVideoDomainModel.h"
#import "ZZVideoRecorder.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoStatuses.h"
#import "ZZStoredSettingsManager.h"
#import "ZZFriendDataProvider.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZVideoDataProvider.h"

#import "NSObject+ANSafeValues.h"
#import "iToast.h"


@interface ZZGridCellViewModel ()

@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
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
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:self.item.relatedUserID];
    return [friendModel videoStatusString];
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
    
    ZZFriendDomainModel *friend = self.item.relatedUser;
    
    if (!friend)
    {
        modelState = ZZGridCellViewModelStateAdd;
    } else {
        if (friend.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently)
        {
            modelState = ZZGridCellViewModelStatePreview | ZZGridCellViewModelStateVideoFailedPermanently;
        }
        else if ((friend.hasApp && self.hasDownloadedVideo) || friend.videos.count > 0)
        {
            modelState = ZZGridCellViewModelStatePreview;
        }
        else
        {
            if (friend.hasApp) {
                modelState = ZZGridCellViewModelStateFriendHasApp;
            } else {
                modelState = ZZGridCellViewModelStateFriendHasNoApp;
            }
        }
    }

    modelState = [self _additionalModelStateWithState:modelState];
    
    return modelState;
}

- (ZZGridCellViewModelState)_additionalModelStateWithState:(ZZGridCellViewModelState)state
{
    ZZGridCellViewModelState stateWithAdditionalState = state;

    ZZFriendDomainModel *friend = self.item.relatedUser;
    
    if (self.hasUploadedVideo &&
        !self.isUploadedVideoViewed &&
        friend.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasUploaded);
    }
    else if (self.isUploadedVideoViewed &&
             friend.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasViewed);
    }
    else if (friend.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading &&
             friend.unviewedCount > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloading);
    }
    else if (friend.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded &&
             !self.item.isDownloadAnimationViewed)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloaded);
    }

    
    // green border state
    if (self.badgeNumber > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateNeedToShowGreenBorder);
    }
    else if (self.badgeNumber == 0 &&
             friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoFirstVideoDownloading);
    }
    
    // badge state
    if (self.badgeNumber == 1
        && friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne);
    }
    else if (self.badgeNumber > 1)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoCountMoreThatOne);
    }
    
    return stateWithAdditionalState;
}


- (void)updateVideoPlayingStateTo:(BOOL)isPlaying
{
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

- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellVeiwModelAnimationDelegate>)animationDelegate
{
    self.animationDelegate = animationDelegate;
    [self _removeActionRecognizerFromView:view];
    [view addGestureRecognizer:self.recordRecognizer];
}

- (void)_removeActionRecognizerFromView:(UIView*)view
{
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull recognizer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        {
            [view removeGestureRecognizer:recognizer];
        }
    }];
}

- (void)setupRecrodHintRecognizerOnView:(UIView*)view
{
    [view addGestureRecognizer:self.tapRecognizer];
}

- (void)removeRecordHintRecognizerFromView:(UIView*)view
{
    [view removeGestureRecognizer:self.tapRecognizer];
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

- (UITapGestureRecognizer *)tapRecognizer
{
    if (!_tapRecognizer)
    {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_showRecorderHing)];
        
    }
    
    return _tapRecognizer;
}

#pragma mark - Private



#pragma mark  - Recording recognizer handle

- (void)_showRecorderHing
{
    [self.delegate showRecorderHint];
}

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (![self.delegate isGridRotate])
    {
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
        else
        {
            [self _checkIsCancelRecordingWithRecognizer:recognizer];
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
            [self.delegate cancelRecordingWithReason:NSLocalizedString(@"record-dragged-finger-away", nil)];
        }
    }
}

#pragma mark - Generate Thumbnail

- (UIImage*)_videoThumbnail
{
    UIImage *image = [ZZThumbnailGenerator lastThumbImageForFriendWithID:self.item.relatedUserID];
    return image;
}


#pragma mark  - Video Play Validation

- (BOOL)isEnablePlayingVideo
{
    return [self.delegate isGridCellEnablePlayingVideo:self];
}

- (BOOL)isVideoPlayed
{
    return [self.delegate isVideoPlayingWithModel:self];
}

- (void)_showMessage:(NSString*)message
{
    [[iToast makeText:message]show];
}

@end
