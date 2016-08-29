//
//  ZZVideoDomainModel+Validation.m
//  Zazo
//
//  Created by Rinat on 29/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZVideoDomainModel+Validation.h"

@import AVKit;
@import AVFoundation;

@implementation ZZVideoDomainModel (Validation)

- (BOOL)isValidVideo
{
    NSError *error = nil;
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    return reader != nil;
}

@end
