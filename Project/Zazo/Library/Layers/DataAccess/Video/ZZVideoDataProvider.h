//
//  ZZVideoDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZVideoDomainModel;
@class TBMVideo;
@class ZZFriendDomainModel;

@interface ZZVideoDataProvider : NSObject

#pragma mark - CRUD

+ (void)deleteItem:(ZZVideoDomainModel*)model;
+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID;

#pragma mark - Count

+ (NSUInteger)countDownloadedUnviewedVideos;
+ (NSUInteger)countDownloadingVideos;
+ (NSUInteger)countTotalUnviewedVideos;
+ (NSUInteger)countAllVideos;


#pragma mark - Load

+ (NSArray*)loadUnviewedVideos; // TODO: load with status ?
+ (NSArray*)loadDownloadingVideos;
+ (NSArray*)loadAllVideos;


+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel;

#pragma mark - Mapping

+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model;
+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;

@end
