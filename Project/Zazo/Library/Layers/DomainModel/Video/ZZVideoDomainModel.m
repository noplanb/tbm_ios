//
//  ZZVideoDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoDomainModel.h"

const struct ZZVideoDomainModelAttributes ZZVideoDomainModelAttributes = {
    .status = @"status",
    .downloadRetryCount = @"downloadRetryCount",
    .relatedUser = @"relatedUser",
    .videoID = @"videoID",
};


@implementation ZZVideoDomainModel

+ (instancetype)createVideo
{
    ZZVideoDomainModel* model = [self new];
    model.status = ZZVideoIncomingStatusNew;
    
    return model;
}

+ (instancetype)createVideoWithItemID:(NSString*)itemID
{
    ZZVideoDomainModel* model = [self createVideo];
    model.videoID = itemID;
    
    return model;
}

@end
