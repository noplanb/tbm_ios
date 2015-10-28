//
//  ZZKeyStoreTransportService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZKeyStoreTransportService.h"
#import "ZZKeyStoreTransport.h"
#import "ZZKeyStoreIncomingVideoIdsDomainModel.h"
#import "ZZKeyStoreOutgoingVideoStatusDomainModel.h"
#import "FEMObjectDeserializer.h"

@implementation ZZKeyStoreTransportService

+ (RACSignal*)getAllIncomingVideoIds
{
    return [[ZZKeyStoreTransport getAllIncomingVideoIds] map:^id(NSArray* videoIdData) {
        videoIdData = [[videoIdData.rac_sequence map:^id(id obj)
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                FEMObjectMapping* mapping = [ZZKeyStoreIncomingVideoIdsDomainModel mapping];
                ZZKeyStoreIncomingVideoIdsDomainModel* model =
                    [FEMObjectDeserializer deserializeObjectExternalRepresentation:obj
                                                                      usingMapping:mapping];
                return model;
            }
            return nil;
        }] array];
        return videoIdData;
    }];
}


+ (RACSignal*)getAllOutgoingVideoStatus{
    return [[ZZKeyStoreTransport getAllOutgoingVideoStatus] map:^id(NSArray* videoStatusData) {
        videoStatusData = [[videoStatusData.rac_sequence map:^id(id obj)
                        {
                            if ([obj isKindOfClass:[NSDictionary class]])
                            {
                                FEMObjectMapping* mapping = [ZZKeyStoreOutgoingVideoStatusDomainModel mapping];
                                ZZKeyStoreOutgoingVideoStatusDomainModel* model =
                                [FEMObjectDeserializer deserializeObjectExternalRepresentation:obj
                                                                                  usingMapping:mapping];
                                return model;
                            }
                            return nil;
                        }] array];
        return videoStatusData;
    }];
}

@end
