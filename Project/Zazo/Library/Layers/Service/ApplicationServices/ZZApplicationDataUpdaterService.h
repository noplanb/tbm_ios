//
//  ZZApplicationDataUpdaterService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@protocol ZZApplicationDataUpdaterServiceDelegate <NSObject>

- (void)freshVideoDetectedWithVideoID:(NSString *)videoID friendID:(NSString *)friendID;

@end

@interface ZZApplicationDataUpdaterService : NSObject

@property (nonatomic, weak) id <ZZApplicationDataUpdaterServiceDelegate> delegate;

- (void)updateAllData;

- (void)updateApplicationBadge;

- (void)updateAllDataWithoutRequest;

@end
