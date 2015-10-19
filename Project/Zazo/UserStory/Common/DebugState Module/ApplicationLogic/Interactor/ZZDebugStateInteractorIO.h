//
//  ZZDebugStateInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZDebugFriendStateDomainModel;

@protocol ZZDebugStateInteractorInput <NSObject>

- (void)loadData;

@end


@protocol ZZDebugStateInteractorOutput <NSObject>

- (void)dataLoadedWithAllVideos:(NSArray*)allVideos incomeDandling:(NSArray*)incomeDandling outcomeDandling:(NSArray*)outcome;

@end