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
#import "ZZMenuEnumsAdditions.h"

@class FEMObjectMapping;

extern const struct ZZFriendDomainModelAttributes {
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
    __unsafe_unretained NSString *connectionStatus;
    __unsafe_unretained NSString *isConnectionCreator;
    __unsafe_unretained NSString *connectionCreatorMkey;
} ZZFriendDomainModelAttributes;

@interface ZZFriendDomainModel : ZZBaseDomainModel <ZZUserInterface>

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;

@property (nonatomic, copy) NSString* mobileNumber;
@property (nonatomic, copy) NSString* mKey;
@property (nonatomic, copy) NSString* cKey;

@property (nonatomic, assign) NSInteger uploadRetryCount;
@property (nonatomic, strong) NSDate* lastActionTimestamp;

@property (nonatomic, assign) NSInteger lastVideoStatusEventType;
@property (nonatomic, assign) NSInteger lastIncomingVideoStatus;

@property (nonatomic, copy) NSString* outgoingVideoItemID;
@property (nonatomic, assign) NSInteger outgoingVideoStatus;
@property (nonatomic, assign) BOOL hasOutgoingVideo;

@property (nonatomic, assign, getter=isHasApp) BOOL hasApp;

@property (nonatomic, copy) NSString* connectionStatus;
@property (nonatomic, assign) BOOL isConnectionCreator;
@property (nonatomic, copy) NSString* connectionCreatorMkey;

@property (nonatomic, assign) ZZConnectionStatusType connectionStatusValue;
@property (nonatomic, assign) ZZMenuContactType contactType;

@property (nonatomic, assign) NSInteger unviewedCount;
@property (nonatomic, assign) NSInteger outgoingVideoStatusValue;


@property (nonatomic, strong) NSArray* videos;

+ (FEMObjectMapping*)mapping;

- (NSString *)fullName;
- (BOOL)isCreator;
- (ZZMenuContactType)contactType;
- (BOOL)hasIncomingVideo;

@end
