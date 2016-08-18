//
//  ZZPlayerController.h
//  Zazo
//
//  Created by Rinat on 08/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZVideoDomainModel;
@class ZZFriendDomainModel;
@class ZZMessageGroup;

typedef void(^ZZShowMessageCompletionBlock)(BOOL shouldContinue);

@protocol ZZPlayerControllerDelegate

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel;
- (void)videoPlayerDidCompletePlaying;

- (void)videoPlayerDidReceiveError:(NSError *)error;

- (void)showMessages:(ZZMessageGroup *)messageGroup completion:(ZZShowMessageCompletionBlock)completion;
- (void)dismissMessages;

@end


@interface ZZPlayerController : NSObject

@property (nonatomic, weak) id<ZZPlayerControllerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isPlayingVideo;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL hideTextMessages;

@property (nonatomic, strong, readonly) UIView *playerView;
@property (nonatomic, strong, readonly) UIView *playbackIndicator;

@property (nonatomic, strong, readonly) ZZFriendDomainModel *friendModel;

- (void)playVideoForFriend:(ZZFriendDomainModel *)friendModel;
- (void)gotoTimestamp:(NSTimeInterval)timestamp;
- (void)stop;

@end
