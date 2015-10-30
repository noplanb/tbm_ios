//
//  ZZKeyStoreDomainModel.h
//  Zazo
//
//  Created by Sani Elfishawy on 10/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ANBaseDomainModel.h"

@class FEMObjectMapping;

extern const struct ZZKeyStoreIncomingVideoIdsDomainModelAttributes {
    __unsafe_unretained NSString *friendMkey;
    __unsafe_unretained NSString *videoIds;
} ZZKeyStoreIncomingVideoIdsDomainModelAttributes;

@interface ZZKeyStoreIncomingVideoIdsDomainModel : ANBaseDomainModel

@property (nonatomic, copy) NSString* friendMkey;
@property (nonatomic, copy) NSSet* videoIds;

+ (FEMObjectMapping*)mapping;

@end
