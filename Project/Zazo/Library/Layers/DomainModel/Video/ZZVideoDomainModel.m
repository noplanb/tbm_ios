//
//  ZZVideoDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoDomainModel.h"
#import "ZZFriendDomainModel.h"

const struct ZZVideoDomainModelAttributes ZZVideoDomainModelAttributes = {
        .videoID = @"videoID",
        .status = @"incomingStatusValue",
        .downloadRetryCount = @"downloadRetryCount",
        .relatedUserID = @"relatedUserID",
        .transcription = @"transcription"
};

@implementation ZZVideoDomainModel

@end
