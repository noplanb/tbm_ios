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
#import "ZZFriendDataProvider.h"
#import "iToast.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZFriendDataHelper.h"


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
    ZZFriendDomainModel* friendModel = self.item.relatedUser;

    NSString* videoStatusString = nil;

    if ([ZZStoredSettingsManager shared].debugModeEnabled)
    {
        videoStatusString = ZZVideoStatusStringWithFriendModel(friendModel);
    }
    else
    {
        videoStatusString = [friendModel displayName];
    }
  
    return videoStatusString;
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
    else if (!ANIsEmpty(self.item.relatedUser) &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently)
    {
        modelState = ZZGridCellViewModelStatePreview | ZZGridCellViewModelStateVideoFailedPermanently;
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
        self.item.relatedUser.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasViewed);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading &&
            [ZZFriendDataHelper unviewedVideoCountWithFriendID:self.item.relatedUser.idTbm] > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloading);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded &&
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
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoFirstVideoDownloading);
    }
    
    // badge state
    if (self.badgeNumber == 1
        && self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
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
    
    if (![ZZThumbnailGenerator hasThumbForVideo:lastModel])
    {
        [ZZThumbnailGenerator generateThumbVideo:lastModel];
    }
    
    return [ZZThumbnailGenerator lastThumbImageForUser:self.item.relatedUser];
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
