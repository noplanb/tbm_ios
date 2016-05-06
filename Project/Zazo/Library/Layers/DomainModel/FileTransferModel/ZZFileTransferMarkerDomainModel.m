//
//  ZZFileTransferMarkerDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFileTransferMarkerDomainModel.h"
#import "FEMObjectMapping.h"
#import "FEMObjectDeserializer.h"
#import "ZZStringUtils.h"
#import "FEMSerializer.h"

const struct ZZFileTransferMarkerDomainModelAttributes ZZFileTransferMarkerDomainModelAttributes = {
        .friendID = @"friendID",
        .videoID = @"videoID",
        .isUpload = @"isUpload",
};

@implementation ZZFileTransferMarkerDomainModel

+ (FEMObjectMapping *)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {

        [mapping addAttributesFromDictionary:@{ZZFileTransferMarkerDomainModelAttributes.videoID : @"videoId",
                ZZFileTransferMarkerDomainModelAttributes.friendID : @"friendId",
                ZZFileTransferMarkerDomainModelAttributes.isUpload : @"isUpload"}];
    }];
}

+ (instancetype)modelWithEncodedMarker:(NSString *)marker
{
    NSDictionary *jsonValue = [ZZStringUtils dictionaryWithJson:marker];
    ZZFileTransferMarkerDomainModel *model = [FEMObjectDeserializer deserializeObjectExternalRepresentation:jsonValue
                                                                                               usingMapping:[self mapping]];
    return model;
}

- (NSString *)markerValue
{
    NSDictionary *jsonValue = [FEMSerializer serializeObject:self
                                                usingMapping:[ZZFileTransferMarkerDomainModel mapping]];
    return [ZZStringUtils jsonWithDictionary:jsonValue];
}

@end
