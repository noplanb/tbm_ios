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
+ (BOOL)generateThumbVideo:(ZZVideoDomainModel*)video;
+ (NSURL*)lastThumbUrlForForUser:(ZZFriendDomainModel*)friendModel;
+ (UIImage*)lastThumbImageForUser:(ZZFriendDomainModel*)friendModel;
+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel*)friendModel;

#pragma mark - Video

+ (NSURL*)thumbUrlForVideo:(ZZVideoDomainModel*)video;
+ (NSString*)thumbPathForVideo:(ZZVideoDomainModel*)video;
+ (BOOL)hasThumbForVideo:(ZZVideoDomainModel*)video;
+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel*)video;
+ (UIImage*)thumbImageForVideo:(ZZVideoDomainModel*)video;

+(UIImage *)lastThumbImageForFriendWithID:(NSString *)friendID;

@end
