//
//  ZZVideoObserver.m
//  Zazo
//
//  Created by Rinat on 04/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZVideoObserver.h"

@class ZZVideoDomainModel;
@class ZZFriendDomainModel;

@interface ZZVideoObserver () <ZZVideoStatusHandlerDelegate>

@property (nonatomic, strong) ZZFriendDomainModel *friendModel;

@end

@implementation ZZVideoObserver

+ (ZZVideoObserver *)observeVideosForFriend:(ZZFriendDomainModel *)friendModel
{
    ZZVideoObserver *observer = [ZZVideoObserver new];
    observer.friendModel = friendModel;
    return observer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self start];
    }
    return self;
}

- (void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_videosDeletedNotification)
                                                 name:ZZVideosDeletedNotification
                                               object:nil];
    
    [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];

}

- (void)stop
{
    [[ZZVideoStatusHandler sharedInstance] removeVideoStatusHandlerObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    
}

- (void)_videosDeletedNotification
{
    ZZLogInfo(@"_videosDeletedNotification");
    
    NSArray <ZZVideoDomainModel *> *availableVideos =
    [ZZVideoDataProvider sortedIncomingVideosForUserWithID:self.friendModel.idTbm];
    
    NSArray <NSString *> *availableVideoIDs = [availableVideos.rac_sequence map:^id(ZZVideoDomainModel *videoModel) {
        return videoModel.videoID;
    }].array;
    
    NSMutableArray <ZZVideoDomainModel *> *unavailableVideos = [NSMutableArray new];
    
    [self.self.friendModel.videos enumerateObjectsUsingBlock:^(ZZVideoDomainModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![availableVideoIDs containsObject:obj.videoID])
        {
            [unavailableVideos addObject:obj];
        }
    }];
    
    if (!ANIsEmpty(unavailableVideos))
    {
        [self.delegate unavailableVideos:unavailableVideos];
    }
}

- (void)videoStatusChangedWithFriendID:(NSString *)friendID;
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    if (![friendID isEqualToString:self.friendModel.idTbm])
    {
        return;
    }
    
    if (friendModel.lastIncomingVideoStatus != ZZVideoIncomingStatusDownloaded)
    {
        return;
    }

    [self.delegate newVideo:friendModel.videos.lastObject];
}

@end
