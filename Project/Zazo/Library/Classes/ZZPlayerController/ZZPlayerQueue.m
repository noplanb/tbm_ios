//
//  ZZPlayerQueue.m
//  Zazo
//
//  Created by Rinat on 04/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZPlayerQueue.h"
#import "ZZPlaybackQueueItem.h"
#import "ZZFileHelper.h"
#import "NSArray+ANAdditions.h"
#import "ZZVideoObserver.h"

@interface ZZPlayerQueue () <ZZVideoObserverDelegate>

@property (nonatomic, assign, readonly) BOOL loadTextMessages;
@property (nonatomic, strong) ZZVideoObserver *observer;

@property (nonatomic, strong, readwrite) NSArray <NSObject<ZZPlaybackQueueItem> *> *models;

// All videos:
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *allVideoModels; // video models passed to player
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *loadedVideoModels; // video models to play

// Text messages:
@property (nonatomic, strong) NSArray <ZZMessageGroup *> *messageGroups;


@end

@implementation ZZPlayerQueue

- (void)dealloc {
    
}

+ (instancetype)queueForFriend:(ZZFriendDomainModel *)friendModel
              withTextMessages:(BOOL)flag
                      delegate:(id<ZZPlayerQueueDelegate>)delegate;
{
    ZZPlayerQueue *instance = [[ZZPlayerQueue alloc] initWithFriendModel:friendModel
                                                        withTextMessages:flag
                                                                delegate:delegate];
    return instance;
}

- (instancetype)initWithFriendModel:(ZZFriendDomainModel *)friendModel
                   withTextMessages:(BOOL)flag
                           delegate:(id<ZZPlayerQueueDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.friendModel = friendModel;
        self.delegate = delegate;
        
        _loadTextMessages = flag;
        _allVideoModels = [self _filterVideoModels:friendModel.videos];
        _messageGroups = @[];
        
        [self _loadVideoModels:self.allVideoModels];
        [self _updateQueue];        
        [self _addObservers];
    }
    return self;
}

- (NSArray <ZZVideoDomainModel *> *)_filterVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    videoModels = [videoModels.rac_sequence filter:^BOOL(ZZVideoDomainModel *videoModel) {
        return (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
                videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
        [ZZFileHelper isFileExistsAtURL:videoModel.videoURL];
    }].array;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return videoModels;
}

- (void)_loadVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    [self.delegate unloadAllVideoModels];
    self.loadedVideoModels = @[];
    
    for (ZZVideoDomainModel *model in videoModels)
    {
        [self _loadModel:model];
    }
}

- (void)_loadModel:(ZZVideoDomainModel *)videoModel
{
    ZZLogInfo(@"Loading video model id = %@", videoModel.videoID);
    self.loadedVideoModels = [self.loadedVideoModels arrayByAddingObject:videoModel];
    [self.delegate loadVideoModel:videoModel];
}

- (void)_addObservers
{
    self.observer = [ZZVideoObserver observeVideosForFriend:self.friendModel];
    self.observer.delegate = self;
}

- (void)_updateQueue
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    NSArray <NSObject<ZZPlaybackQueueItem> *> *items = self.allVideoModels;
    
    if (self.loadTextMessages)
    {
        items = [items arrayByAddingObjectsFromArray:self.friendModel.messages];
    }
    
    items = [items sortedArrayUsingDescriptors:@[descriptor]];
    
    NSMutableArray *result = [NSMutableArray new];
    __block ZZMessageGroup *group = [ZZMessageGroup new];
    
    dispatch_block_t finishGroupIfNeeded = ^{
        if (group.messages.count > 0)
        {
            [result addObject:group];
            self.messageGroups = [self.messageGroups arrayByAddingObject:group];
            group = [ZZMessageGroup new];
        }
    };
    
    for (NSObject<ZZPlaybackQueueItem> *item in items)
    {
        if ([item type] == ZZIncomingEventTypeVideo)
        {
            finishGroupIfNeeded();
            [result addObject:item];
        }
        else if ([item type] == ZZIncomingEventTypeMessage)
        {
            if (![item isKindOfClass:[ZZMessageDomainModel class]]) {
                continue;
            }
            
            ZZMessageDomainModel *messageModel = (id)item;
            
            if (group.messages.count == 0)
            {
                group.name = self.friendModel.fullName;
            }
            
            [group addMessage:messageModel];            
        }
    }
    
    finishGroupIfNeeded();
    self.models = [result copy];
}


- (NSObject<ZZPlaybackQueueItem> *)itemAfterTimestamp:(NSTimeInterval)timestamp
{
    for (NSObject<ZZPlaybackQueueItem> *item in self.models) {
        if ([item timestamp] > timestamp) {
            return item;
        }
    }
    
    return nil;
}

- (ZZMessageGroup *)messageGroupAfterTimestamp:(NSTimeInterval)timestamp
{
    for (ZZMessageGroup *messageGroup in self.messageGroups) {
        if ([messageGroup timestamp] > timestamp) {
            return messageGroup;
        }
    }
    
    return nil;
}

- (void)_unloadVideoModel:(ZZVideoDomainModel *)videoModel
{
    NSInteger index = [self.loadedVideoModels indexOfObject:videoModel];
    
    if (index == NSNotFound)
    {
        return;
    }
    
    ZZLogInfo(@"Unloading %@ | index = %ld", videoModel.videoID, (long)index);
    self.loadedVideoModels = [self.loadedVideoModels zz_arrayWithoutObject:videoModel];
    self.allVideoModels = [self.allVideoModels zz_arrayWithoutObject:videoModel];
    [self _updateQueue];
    
    
    [self.delegate unloadVideoModel:videoModel];
}

- (void)reloadWithSkip:(NSUInteger)count
{
    NSRange rangeToPlay = NSMakeRange(count, self.models.count - count);
    NSArray *models = [self.models subarrayWithRange:rangeToPlay];
    
    models = [models.rac_sequence filter:^BOOL(NSObject <ZZPlaybackQueueItem> *item) {
        return item.type == ZZIncomingEventTypeVideo;
    }].array;
    
    [self _loadVideoModels:models];
}

#pragma mark ZZVideoObserverDelegate

- (void)newVideo:(ZZVideoDomainModel *)videoModel
{
    [self.delegate queueWillChange];
    
    NSArray <NSString *> *videoIDs = [self.loadedVideoModels.rac_sequence map:^id(ZZVideoDomainModel *videoModel) {
        return videoModel.videoID;
    }].array;
    
    if ([videoIDs containsObject:videoModel.videoID])
    {
        return;
    }
    
    ZZLogInfo(@"Appending video id = %@", videoModel.videoID);
    
    [self _loadModel:videoModel];
    
    self.allVideoModels = [self.allVideoModels arrayByAddingObject:videoModel];
    [self _updateQueue];
    
    [self.delegate queueDidChange];

}

- (void)unavailableVideos:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    [self.delegate queueWillChange];
    
    ZZLogInfo(@"videos unavailable: %lu", (unsigned long) videoModels.count);
    
    [videoModels enumerateObjectsUsingBlock:^(ZZVideoDomainModel * _Nonnull videoModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _unloadVideoModel:videoModel];
    }];
    
    ZZLogInfo(@"videos loaded: %lu", (unsigned long) self.loadedVideoModels.count);
    
    [self.delegate queueDidChange];
    //    [self _startPlayingIfPossible];

}


@end
