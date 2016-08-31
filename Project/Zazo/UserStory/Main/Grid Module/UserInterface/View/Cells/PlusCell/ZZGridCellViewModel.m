//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZGridCellViewModel.h"
#import "ZZVideoDomainModel.h"
#import "ZZThumbnailGenerator.h"
#import "ZZStoredSettingsManager.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZFriendDataHelper.h"


@interface ZZGridCellViewModel ()

@property (nonatomic, strong) UILongPressGestureRecognizer *recordRecognizer;
@property (nonatomic, assign) CGPoint initialRecordPoint;

@end

@implementation ZZGridCellViewModel

@dynamic isRecording;

- (void)setUsernameLabel:(UILabel *)usernameLabel
{
    _usernameLabel = usernameLabel;
    ANDispatchBlockToMainQueue(^{

        _usernameLabel.text = [self videoStatusString];
    });
}

- (NSString *)_stubUserNameForIndex:(NSUInteger)index
{
    NSArray *stubNames = @[
            @"Leila",
            @"Nia",
            @"Shani",
            @"Gabby",
            @"Mary",
            @"Sachi",
            @"Alexis",
            @"Veronika"
    ];

    return stubNames[index];
}

- (NSString *)videoStatusString
{

#ifdef MAKING_SCREENSHOTS
    return [self _stubUserNameForIndex:self.item.index];
#endif


    ZZFriendDomainModel *friendModel = self.item.relatedUser;

    NSString *videoStatusString = nil;

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

- (void)reloadDebugVideoStatus
{
    ANDispatchBlockToMainQueue(^{
        self.usernameLabel.text = [self videoStatusString];
    });
}

- (BOOL)isRecording
{
    return !CGPointEqualToPoint(self.initialRecordPoint, CGPointZero);
}

- (ZZCellState)friendState
{
    if (!self.item.relatedUser)
    {
        return ZZCellStateAdd;
    }
    
    if (self.hasThumbnail)
    {
        return ZZCellStatePreview;
    }
    
    if (self.item.relatedUser.lastIncomingVideoStatus > ZZVideoIncomingStatusNew)
    {
        return ZZCellStateHasApp;
    }

    else
    {
        return ZZCellStateHasNoApp;
    }

    return ZZCellStateNone;
}

- (ZZCellVideoState)videoState
{
    ZZIncomingEventType eventType = self.item.relatedUser.lastEventType;
    
    if (eventType == ZZIncomingEventTypeMessage)
    {
        return ZZCellVideoStateNone;
    }
    
    ZZVideoStatusEventType videoEvent = self.item.relatedUser.lastVideoStatusEventType;
    ZZVideoIncomingStatus incomingStatus = self.item.relatedUser.lastIncomingVideoStatus;
    
    if (self.hasUploadedVideo &&
        !self.isUploadedVideoViewed &&
        videoEvent != ZZVideoStatusEventTypeIncoming &&
        self.item.relatedUser.lastOutgoingVideoStatus >= ZZVideoOutgoingStatusUploaded)
    {
        return ZZCellVideoStateUploaded;
    }
    
    if (videoEvent == ZZVideoStatusEventTypeIncoming &&
        incomingStatus == ZZVideoIncomingStatusDownloading)
//         && [ZZFriendDataHelper unviewedVideoCountWithFriendID:self.item.relatedUser.idTbm] > 0)
    {
        return ZZCellVideoStateDownloading;
    }
    
    if (videoEvent == ZZVideoStatusEventTypeIncoming &&
        incomingStatus == ZZVideoIncomingStatusDownloaded)
//         && !self.item.isDownloadAnimationViewed)
    {
        return ZZCellVideoStateDownloaded;
    }

    if (self.isUploadedVideoViewed &&
        videoEvent != ZZVideoStatusEventTypeIncoming)
    {
        return ZZCellVideoStateViewed;
    }
    
    if (videoEvent == ZZVideoStatusEventTypeIncoming &&
        incomingStatus == ZZVideoIncomingStatusFailedPermanently)
    {
        return ZZCellVideoStateFailed;
    }
    
    return ZZCellVideoStateNone;
    
//    if (self.badgeNumber > 0)
//    {
//        stateWithvideoState = (stateWithvideoState | ZZGridCellViewModelStateNeedToShowBorder);
//    }    

}

- (NSString *)firstName
{
    return [NSObject an_safeString:self.item.relatedUser.firstName];
}

#pragma mark - Video Thumbnail

- (UIImage *)videoThumbnailImage
{

#ifdef MAKING_SCREENSHOTS
    return [UIImage imageNamed:[NSString stringWithFormat:@"prethumb%ld", (long)self.item.index + 1]];
#endif

    return [self _videoThumbnail];
}

- (void)setupRecorderRecognizerOnView:(UIView *)view
                withAnimationDelegate:(id <ZZGridCellViewModelAnimationDelegate>)animationDelegate
{
    self.animationDelegate = animationDelegate;
    [self _removeActionRecognizerFromView:view];
    [view addGestureRecognizer:self.recordRecognizer];
}

- (void)_removeActionRecognizerFromView:(UIView *)view
{
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *_Nonnull recognizer, NSUInteger idx, BOOL *_Nonnull stop) {
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

#pragma mark  - Recording recognizer handle

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (![self.presenter isGridRotate])
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            self.initialRecordPoint = [recognizer locationInView:recognizer.view];

            [self didChangeRecordingState:YES completion:^(BOOL isRecordingSuccess) {
                if (isRecordingSuccess)
                {
                    self.hasUploadedVideo = YES;
                    [self.animationDelegate showUploadAnimation];
                    self.usernameLabel.text = [self videoStatusString];
                }
            }];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
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
    [self didChangeRecordingState:NO completion:^(BOOL isRecordingSuccess) {
        if (isRecordingSuccess)
        {
            self.hasUploadedVideo = YES;
            [self.animationDelegate showUploadAnimation];
            self.usernameLabel.text = [self videoStatusString];
        }
    }];
}

- (void)_checkIsCancelRecordingWithRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    if ([ZZGridActionStoredSettings shared].abortRecordingFeatureEnabled)
    {
        CGFloat addTouchBounds = 80;
        if (IS_IPAD)
        {
            addTouchBounds *= 2;
        }

        UIView *recordView = recognizer.view;

        CGPoint location = [recognizer locationInView:recordView];

        CGRect observeFrame = CGRectMake(self.initialRecordPoint.x - addTouchBounds,
                self.initialRecordPoint.y - addTouchBounds,
                (addTouchBounds * 2),
                (addTouchBounds * 2));
        if (!CGRectContainsPoint(observeFrame, location))
        {
            [self.presenter cancelRecordingWithReason:NSLocalizedString(@"record-dragged-finger-away", nil)];
        }
    }
}

#pragma mark - Generate Thumbnail

- (UIImage *)_videoThumbnail
{
    NSSortDescriptor *sortDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];

    NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"%K = %@", ZZVideoDomainModelAttributes.status, @(ZZVideoIncomingStatusDownloaded)];

    NSArray *videoModels = self.item.relatedUser.videos;

    videoModels = [videoModels filteredArrayUsingPredicate:predicate];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];

    ZZVideoDomainModel *lastModel = [videoModels lastObject];

    if (![ZZThumbnailGenerator hasThumbForVideo:lastModel])
    {
        [ZZThumbnailGenerator generateThumbVideo:lastModel];
    }

    return [ZZThumbnailGenerator lastThumbImageForFriendID :self.item.relatedUser.idTbm];
}


#pragma mark  - Video Play Validation

- (BOOL)isEnablePlayingVideo
{
    return [self.presenter isGridCellEnablePlayingVideo:self];
}

// MARK: Events

- (void)didTapEmptyCell
{
    if (![self.presenter isGridRotate])
    {
        [self.presenter addUserToItem:self];
    }
}

- (void)didChangeRecordingState:(BOOL)isRecording
                     completion:(void (^)(BOOL isRecordingSuccess))completionBlock
{
    [self.presenter viewModel:self
      didChangeRecordingState:isRecording
                   completion:completionBlock];

    [self reloadDebugVideoStatus];
}

- (void)didTapCell
{
    BOOL canPlay = self.hasMessages || self.hasDownloadedVideo;
    
    if (!canPlay)
    {
        return;
    }
    
    [self.presenter viewModelDidTapCell:self];
    [self reloadDebugVideoStatus];
}

- (void)didTapOverflowButton:(UIButton *)button
{
    if (self.videoState == ZZCellVideoStateDownloading)
    {
        return;
    }
    
    [self.presenter viewModelDidTapOverflowButton:self];
}

@end