//
//  ZZVideoObserver.h
//  Zazo
//
//  Created by Rinat on 04/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZVideoObserverDelegate <NSObject>

- (void)newVideo:(ZZVideoDomainModel *)videoModel;
- (void)unavailableVideos:(NSArray <ZZVideoDomainModel *> *)videos;

@end

@interface ZZVideoObserver: NSObject

+ (ZZVideoObserver *)observeVideosForFriend:(ZZFriendDomainModel *)friendModel;
@property (nonatomic, weak) id<ZZVideoObserverDelegate> delegate;

@end
