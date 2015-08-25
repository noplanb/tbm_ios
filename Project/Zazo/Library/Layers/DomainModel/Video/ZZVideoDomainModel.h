//
//  ZZVideoDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"
#import "ZZVideoStatuses.h"

@class ZZFriendDomainModel;

extern const struct ZZVideoDomainModelAttributes {
    __unsafe_unretained NSString *status;
    __unsafe_unretained NSString *downloadRetryCount;
    __unsafe_unretained NSString *relatedUser;
    __unsafe_unretained NSString *videoID;
} ZZVideoDomainModelAttributes;

@interface ZZVideoDomainModel : ZZBaseDomainModel

@property (nonatomic, assign) ZZVideoIncomingStatus status;
@property (nonatomic, assign) NSInteger downloadRetryCount;
@property (nonatomic, strong) ZZFriendDomainModel* relatedUser;
@property (nonatomic, copy) NSString* videoID;

+ (instancetype)createVideo;
+ (instancetype)createVideoWithItemID:(NSString*)itemID;

@end
