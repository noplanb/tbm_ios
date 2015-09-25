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
#import "ZZFeatureObserver.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoStatuses.h"
#import "ZZStoredSettingsManager.h"
#import "TBMFriend.h"
#import "ZZFriendDataProvider.h"

@interface ZZGridCellViewModel ()

@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;
@property (nonatomic, strong) NSMutableArray* recognizerStatesArray;

@end

@implementation ZZGridCellViewModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.recognizerStatesArray = [NSMutableArray array];
        
        
        
        
        
        
        
        
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
    if (YES)//([ZZStoredSettingsManager shared].debugModeEnabled) //TODO:
    {
        ZZFriendDomainModel* friendModel = self.item.relatedUser;
        TBMFriend* friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
        
        return friendEntity.videoStatusString;
    }
    else
    {
        return [self firstName];
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

//- (void)stopRecording
//{
//    [self.delegate recordingStateUpdatedToState:NO viewModel:self];
////    self.hasUploadedVideo = YES; // TODO:
//}

- (ZZGridCellViewModelState)state
{
    if (self.item.relatedUser.hasApp && self.hasDownloadedVideo)
    {
        return ZZGridCellViewModelStateIncomingVideoNotViewed;
    }
    else if (!self.item.relatedUser)
    {
        return ZZGridCellViewModelStateAdd;
    }
    else if (self.item.relatedUser.videos.count > 0) // TODO: this condition only for test!, change it later
    {
        return ZZGridCellViewModelStateIncomingVideoNotViewed;
    }
    else if (self.item.relatedUser.hasApp)
    {
        return ZZGridCellViewModelStateFriendHasApp;
    }
    else if (!self.item.relatedUser.hasApp)
    {
        return ZZGridCellViewModelStateFriendHasNoApp;
    }
    
    return 0;
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
    [self reloadDebugVideoStatus];
    [self.delegate nudgeSelectedWithUserModel:self.item.relatedUser];
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

- (UIImage *)videoThumbnailImage
{
    return [self _videoThumbnail];
}

- (void)setBadgeNumber:(NSNumber *)badgeNumber
{
    _badgeNumber = badgeNumber;
}


- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellVeiwModelAnimationDelegate>)animationDelegate
{
    self.animationDelegate = animationDelegate;
    [view addGestureRecognizer:self.recordRecognizer];
}

- (UILongPressGestureRecognizer *)recordRecognizer
{
    if (!_recordRecognizer)
    {
        _recordRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_recordPressed:)];
        _recordRecognizer.minimumPressDuration = 0.5;
    }
    return _recordRecognizer;
}



#pragma mark - Private


#pragma mark  - Recording recognizer handle

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{

        [self _checkIsCancelRecordingWithRecognizer:recognizer];
        
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            [self updateRecordingStateTo:YES withCompletionBlock:nil];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded)
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
    
}

- (void)_checkIsCancelRecordingWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if ([ZZFeatureObserver sharedInstance].isRecordAbortWithDraggedEnabled)
    {
        UIView* recordView = recognizer.view;
        CGPoint location = [recognizer locationInView:recordView];
        if (!CGRectContainsPoint(recordView.frame,location))
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
    ZZVideoDomainModel* model = [self.item.relatedUser.videos firstObject];
    [ZZThumbnailGenerator generateThumbVideo:model];
    
    return [ZZThumbnailGenerator lastThumbImageForUser:self.item.relatedUser];
}

@end
