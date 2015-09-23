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

//- (NSURL*)videoURL
//{
//    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", self.relatedUser.idTbm, self.videoID];
//    NSURL* URL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
//    return [URL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
//}

@end
