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

+ (UIImage *)thumbImageForUser:(ZZFriendDomainModel *)friendModel;

+ (BOOL)isThumbNoPicForUser:(ZZFriendDomainModel *)friendModel;

+ (BOOL)generateThumbVideo:(ZZVideoDomainModel *)video;

+ (NSURL *)lastThumbUrlForForUserWithID:(NSString *)friendID;

+ (UIImage *)lastThumbImageForFriendID:(NSString *)friendID;

+ (BOOL)hasLastThumbForUser:(ZZFriendDomainModel *)friendModel;

+ (void)deleteLastThumbForUserWithID:(NSString *)friendID;

+ (UIImage *)legacyThumbImageForFriend:(ZZFriendDomainModel *)friendModel;

+ (BOOL)hasLegacyThumbForUser:(ZZFriendDomainModel *)friendModel;

+ (UIImage *)thumbnailPlaceholderImageForName:(NSString *)name;

#pragma mark - Video

+ (UIImage *)imageForVideo:(ZZVideoDomainModel *)video;

+ (NSURL *)thumbUrlForVideo:(ZZVideoDomainModel *)video;

+ (NSString *)thumbPathForVideo:(ZZVideoDomainModel *)video;

+ (BOOL)hasThumbForVideo:(ZZVideoDomainModel *)video;

+ (void)deleteThumbFileForVideo:(ZZVideoDomainModel *)video;

@end
