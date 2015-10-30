//
//  ZZKeyStoreDomainModel.m
//  Zazo
//
//  Created by Sani Elfishawy on 10/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZKeyStoreIncomingVideoIdsDomainModel.h"
#import "FEMObjectMapping.h"

const struct ZZKeyStoreIncomingVideoIdsDomainModelAttributes ZZKeyStoreIncomingVideoIdsDomainModelAttributes = {
    .friendMkey = @"friendMkey",
    .videoIds = @"videoIds",
};

@implementation ZZKeyStoreIncomingVideoIdsDomainModel

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        
        [mapping addAttributesFromDictionary:@{ZZKeyStoreIncomingVideoIdsDomainModelAttributes.friendMkey    : @"mkey",
              ZZKeyStoreIncomingVideoIdsDomainModelAttributes.videoIds      : @"video_ids"}
         ];
    }];
}


@end
