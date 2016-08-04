//
//  ZZPlayerQueue.h
//  Zazo
//
//  Created by Rinat on 04/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZSegmentSchemeItem.h"

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
@property (nonatomic, strong, readonly) NSArray <NSObject<ZZSegmentSchemeItem> *> *models; // Text + video

- (NSObject <ZZSegmentSchemeItem> *)itemAfterTimestamp:(NSTimeInterval)timestamp;
- (ZZMessageDomainModel *)messageAfterTimestamp:(NSTimeInterval)timestamp;

//@property (nonatomic, strong, readonly) ZZVideoDomainModel *currentVideoModel;

- (void)reloadWithSkip:(NSUInteger)count;

@end
