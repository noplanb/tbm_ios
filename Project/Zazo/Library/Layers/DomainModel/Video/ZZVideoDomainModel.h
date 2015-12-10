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
    __unsafe_unretained NSString *videoID;
    __unsafe_unretained NSString *incomingStatusValue;
    __unsafe_unretained NSString *downloadRetryCount;
    __unsafe_unretained NSString *relatedUser;
    __unsafe_unretained NSString *relatedUserID;
    
} ZZVideoDomainModelAttributes;

@interface ZZVideoDomainModel : ZZBaseDomainModel

@property (nonatomic, copy) NSString* videoID;
@property (nonatomic, assign) ZZVideoIncomingStatus incomingStatusValue; //TODO: found better name 
@property (nonatomic, assign) NSInteger downloadRetryCount;
@property (nonatomic, strong) ZZFriendDomainModel* relatedUser;
@property (nonatomic, copy) NSString*  relatedUserID;
@property (nonatomic, strong) NSURL* videoURL;

@end
