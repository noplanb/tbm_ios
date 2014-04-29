//
//  TBMVideoPlayer.m
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoPlayer.h"
#import "TBMVideoRecorder.h"
#import "MediaPlayer/MediaPlayer.h"

@implementation TBMVideoPlayer
+ (void)playWIthView:(UIView *)playView friendId:(NSNumber *)friendId{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *videoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:friendId];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:videoUrl.path error:&error];
    NSLog(@"TBMVideoPlayer: playing for friend %@. Filesize=%llu", friendId, fileAttributes.fileSize);
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    [player.view setFrame: playView.bounds];
    [playView addSubview:player.view];
    [player prepareToPlay];
    [player play];
}

@end
