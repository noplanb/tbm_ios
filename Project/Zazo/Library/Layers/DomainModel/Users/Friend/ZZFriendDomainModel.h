//
//  ZZFriendDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"
#import "ZZUserInterface.h"
#import "ZZEditFriendEnumsAdditions.h"
#import "ZZContactEnumsAdditions.h"
#import "ZZVideoStatuses.h"
#import "ZZMessageDomainModel.h"
#import "ZZAbilities.h"

@class FEMObjectMapping, ZZVideoDomainModel;

extern const struct ZZFriendDomainModelAttributes
{
    __unsafe_unretained NSString *idTbm;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *mobileNumber;
    __unsafe_unretained NSString *mKey;
    __unsafe_unretained NSString *cKey;
    __unsafe_unretained NSString *uploadRetryCount;
    __unsafe_unretained NSString *lastActionTimestamp;
    __unsafe_unretained NSString *lastVideoStatusEventType;
    __unsafe_unretained NSString *lastIncomingVideoStatus;
    __unsafe_unretained NSString *outgoingVideoItemID;
    __unsafe_unretained NSString *outgoingVideoStatus;
    __unsafe_unretained NSString *hasApp;
    __unsafe_unretained NSString *friendshipStatus;
    __unsafe_unretained NSString *isFriendshipCreator;
    __unsafe_unretained NSString *friendshipCreatorMkey;
    __unsafe_unretained NSString *abilities;
    __unsafe_unretained NSString *abilitiesArray;
    __unsafe_unretained NSString *cid;
    __unsafe_unretained NSString *avatarTimestamp;
    __unsafe_unretained NSString *useAsThumbnail;
    
} ZZFriendDomainModelAttributes;

@interface ZZFriendDomainModel : ZZBaseDomainModel <ZZUserInterface>

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString *idTbm;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *mobileNumber;
@property (nonatomic, copy) NSString *mKey;
@property (nonatomic, copy) NSString *cKey;

@property (nonatomic, assign) NSInteger uploadRetryCount;
@property (nonatomic, strong) NSDate *lastActionTimestamp;

@property (nonatomic, assign) ZZVideoStatusEventType lastVideoStatusEventType;
@property (nonatomic, assign) ZZVideoIncomingStatus lastIncomingVideoStatus;
@property (nonatomic, assign) BOOL everSent;
@property (nonatomic, assign) ZZIncomingEventType lastEventType;

@property (nonatomic, copy) NSString *outgoingVideoItemID;

@property (nonatomic, assign) BOOL hasOutgoingVideo;

@property (nonatomic, assign, getter=isHasApp) BOOL hasApp;

@property (nonatomic, copy) NSString *friendshipStatus;
@property (nonatomic, copy) NSString *friendshipCreatorMkey;

@property (nonatomic, assign) ZZFriendshipStatusType friendshipStatusValue;
@property (nonatomic, assign) ZZMenuContactType contactType;

@property (nonatomic, assign) ZZVideoOutgoingStatus lastOutgoingVideoStatus;

@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *videos;
@property (nonatomic, strong) NSArray <ZZMessageDomainModel *> *messages;

@property (nonatomic, assign) ZZFriendAbilities abilities;
@property (nonatomic, strong) NSArray <NSString *> *abilitiesArray;

@property (nonatomic, assign) UInt64 avatarTimestamp;
@property (nonatomic, strong) NSString *useAsThumbnail;

+ (FEMObjectMapping *)mapping;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)shortFirstName;
- (ZZMenuContactType)contactType;

- (BOOL)isCreator;

- (BOOL)hasIncomingVideo;
- (BOOL)hasDownloadedVideo;
- (BOOL)hasDownloadingVideo;

@end
