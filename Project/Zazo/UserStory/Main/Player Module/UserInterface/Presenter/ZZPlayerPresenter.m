
//
//  ZZPlayerPresenter.m
//  Zazo
//

#import "ZZPlayerPresenter.h"
#import "ZZPlayer.h"

@import UIKit;

#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "iToast.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZRemoteStorageTransportService.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataHelper.h"
#import "ZZFriendDataUpdater.h"
#import "NSDate+ZZAdditions.h"
#import "ZZPlayerWireframe.h"
#import "ZZPlayerController.h"


@interface ZZPlayerPresenter () <ZZPlayerControllerDelegate>

@property (nonatomic, strong) ZZPlayerController *playerController;

@end

@implementation ZZPlayerPresenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _playerController = [ZZPlayerController new];
        _playerController.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_applicationWillResignNotication)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        
    }
    return self;
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZPlayerViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
    [self.userInterface view]; // loading view
    
    self.userInterface.playerView = self.playerController.playerView;
    self.userInterface.playbackIndicator = self.playerController.playbackIndicator;
}

- (void)appendLastVideoFromFriendModel:(ZZFriendDomainModel *)friendModel
{
    [self.playerController appendLastVideoFromFriendModel:friendModel];
}

- (void)playVideoForFriend:(ZZFriendDomainModel *)friendModel
{
    [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;

    [self _setPlayerVisible:YES];

    [self.playerController playVideoForFriend:friendModel];
    
    [self _updatePlayersFrame];
    
}

- (BOOL)isPlayingVideo
{
    return self.playerController.isPlayingVideo;
}

#pragma mark Player Controller delegate

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel isLastVideo:(BOOL)isLastVideo
{
    [self.delegate videoPlayerDidStartVideoModel:videoModel];
    
    [self _showDateForVideoModel:videoModel];
    
    [[ZZVideoStatusHandler sharedInstance]
     setAndNotityViewedIncomingVideoWithFriendID:self.playerController.currentFriendModel.idTbm videoID:videoModel.videoID];
    
    [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:videoModel.videoID
                                                                  toStatus:ZZRemoteStorageVideoStatusViewed
                                                                friendMkey:self.playerController.currentFriendModel.mKey
                                                                friendCKey:self.playerController.currentFriendModel.cKey] subscribeNext:^(id x) {}];
    
    [ZZVideoStatusHandler sharedInstance].currentlyPlayedVideoID = videoModel.videoID;

    if (!isLastVideo) {
        return;
    }
    
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];
    
    if (friendModel.lastIncomingVideoStatus != videoModel.incomingStatusValue)
    {
        friendModel.lastIncomingVideoStatus = videoModel.incomingStatusValue;

        [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm
                     setLastIncomingVideoStatus: videoModel.incomingStatusValue];
    }
}

- (void)videoPlayerDidReceiveError:(NSError *)error
{
    [[iToast makeText:NSLocalizedString(@"video-player-not-playable", nil)] show];
}

- (void)videoPlayerDidCompletePlaying
{
    [self _setPlayerVisible:NO];
    [self.delegate videoPlayerDidFinishPlayingWithModel:self.playerController.currentFriendModel];
}

#pragma mark UI events

- (void)didTapVideo
{
    if (self.playerController.isPlayingVideo)
    {
        [self stop];
    }
//    else
//    {
//        [self _loadVideoModels:self.allVideoModels];
//        [self _startPlayingIfPossible];
//    }
}

#pragma mark - Public

//- (ZZVideoDomainModel *)_actualVideoDomainModelWithSortedModels:(NSArray *)models
//{
//    ZZVideoDomainModel* actualVideoModel = [models firstObject];
//
//    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:actualVideoModel.relatedUserID];
//
//    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:actualVideoModel.videoID];
//
//    NSInteger twoNotViewedVideosCount = 2;
//    NSUInteger nextVideoIndex = 1;
//
//    if ((friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading) &&
//        ([ZZFriendDataHelper unviewedVideoCountWithFriendID:friendModel.idTbm] == twoNotViewedVideosCount) &&
//        videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed)
//    {
//        actualVideoModel = models[nextVideoIndex];
//    }
//
//    return actualVideoModel;
//}



- (void)_updatePlayersFrame
{
    CGRect cellFrame = [self.grid frameOfViewForFriendModelWithID:self.playerController.currentFriendModel.idTbm];
    
    cellFrame = [self.userInterface.view convertRect:cellFrame
                                            fromView:self.userInterface.view.window];
    
    CGFloat ZZCellBorderWidth = 4;
    
    cellFrame = CGRectOffset(cellFrame, -ZZCellBorderWidth, -ZZCellBorderWidth);
    
    self.userInterface.initialPlayerFrame = cellFrame;

}

- (void)stop
{
    [self.playerController stop];
    [self _setPlayerVisible:NO];
}

- (ZZFriendDomainModel *)playedFriendModel
{
    return self.playerController.currentFriendModel;
}

- (void)showFullscreen
{
    [self.userInterface setFullscreenEnabled:YES completion:nil];
}

#pragma mark - Private


- (void)_showDateForVideoModel:(ZZVideoDomainModel *)videoModel
{
    NSTimeInterval timestamp = videoModel.videoID.doubleValue / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    [self.userInterface updatePlayerText:[date zz_formattedDate]];
}

//- (NSTimeInterval)_durationByURL:(NSURL *)url
//{
//    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:url options:nil];
//    CMTime duration = sourceAsset.duration;
//    return CMTimeGetSeconds(duration);
//}

#pragma mark - Properties

- (void)_setPlayerVisible:(BOOL)playerVisible
{
    ANCodeBlock settingBlock = ^{
        self.wireframe.playerVisible = playerVisible;
    };
    
    if (playerVisible)
    {
        settingBlock();
        return;
    }
    
    [self.userInterface setFullscreenEnabled:NO completion:settingBlock];
}


#pragma mark Events

- (void)_applicationWillResignNotication
{
    [self stop];
}


@end
