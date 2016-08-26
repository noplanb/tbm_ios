//
//  ZZPlayerQueue.h
//  Zazo
//
//  Created by Rinat on 04/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZPlaybackQueueItem.h"
#import "ZZMessageGroup.h"

@class ZZPlayerQueue;

@protocol ZZPlayerQueueDelegate <NSObject>

- (void)queueWillChange;
- (void)queueDidChange;
- (void)loadVideoModel:(ZZVideoDomainModel *)videoModel;
- (void)unloadVideoModel:(ZZVideoDomainModel *)videoModel;
- (void)unloadAllVideoModels;

@end

@interface ZZPlayerQueue : NSObject

+ (instancetype)queueForFriend:(ZZFriendDomainModel *)friendModel
              withTextMessages:(BOOL)flag
                      delegate:(id<ZZPlayerQueueDelegate>)delegate;

@property (nonatomic, weak) id<ZZPlayerQueueDelegate> delegate;
@property (nonatomic, strong, readwrite) ZZFriendDomainModel *friendModel;
@property (nonatomic, strong, readonly) NSArray <NSObject<ZZPlaybackQueueItem> *> *models; // Text + video

- (NSObject <ZZPlaybackQueueItem> *)itemAfterTimestamp:(NSTimeInterval)timestamp;
- (ZZMessageGroup *)messageGroupAfterTimestamp:(NSTimeInterval)timestamp;

//@property (nonatomic, strong, readonly) ZZVideoDomainModel *currentVideoModel;
@property (nonatomic, assign) BOOL appendNewItems;

- (void)reloadWithSkip:(NSUInteger)count;

@end
