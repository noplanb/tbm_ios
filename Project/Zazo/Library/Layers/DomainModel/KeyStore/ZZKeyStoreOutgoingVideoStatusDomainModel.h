//
//  ZZKeyStoreOutgoingVideoStatusDomainModel.h
//  Zazo
//
//  Created by Sani Elfishawy on 10/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ANBaseDomainModel.h"
#import "TBMFriend.h"
#import "ZZVideoStatuses.h"

@class FEMObjectMapping;

extern const struct ZZKeyStoreOutgoingVideoStatusDomainModelAttributes
{
    __unsafe_unretained NSString *friendMkey;
    __unsafe_unretained NSString *statusNumber;
    __unsafe_unretained NSString *videoId;
} ZZKeyStoreOutgoingVideoStatusDomainModelAttributes;


extern const struct ZZKeyStoreOutgoingVideoStatusValues
{
    __unsafe_unretained NSString *outgoingVideoStatusDownloaded;
    __unsafe_unretained NSString *outgoingVideoStatusViewed;
} ZZKeyStoreOutgoingVideoStatusValues;

@interface ZZKeyStoreOutgoingVideoStatusDomainModel : ANBaseDomainModel

@property (nonatomic, copy) NSString *friendMkey;
@property (nonatomic, assign) NSNumber *statusNumber;
@property (nonatomic, copy) NSString *videoId;

+ (FEMObjectMapping *)mapping;

- (ZZVideoOutgoingStatus)status;

@end
