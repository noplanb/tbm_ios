//
//  ZZThumbnailGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZFriendDomainModel;
@class ZZVideoDomainModel;

@interface ZZThumbnailGenerator : NSObject

+ (UIImage*)thumbImageForUser:(ZZFriendDomainModel*)friendModel;
+ (BOOL)isThumbNoPicForUser:(ZZFriendDomainModel*)friendModel;
+ (void)generateThumbVideo:(ZZVideoDomainModel*)video;
+ (void)copyToLastThumbWithVideo:(ZZVideoDomainModel*)video;
+ (NSURL*)lastThumbUrlForForUser:(ZZFriendDomainModel*)friendModel;
+ (UIImage*)lastThumbImageForUser:(ZZFriendDomainModel*)friendModel;
+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel*)friendModel;
+ (void)deleteLastThumbForUser:(ZZFriendDomainModel*)friendModel;
+ (UIImage*)legacyThumbImageForFriend:(ZZFriendDomainModel*)friendModel;
+ (BOOL)hasLegacyThumbForUser:(ZZFriendDomainModel*)friendModel;


#pragma mark - Video

+ (NSURL*)thumbUrlForVideo:(ZZVideoDomainModel*)video;
+ (NSString*)thumbPathForVideo:(ZZVideoDomainModel*)video;
+ (BOOL)hasThumbForVideo:(ZZVideoDomainModel*)video;
+ (BOOL)generateThumbForVideo:(ZZVideoDomainModel*)video;
+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel*)video;

@end
