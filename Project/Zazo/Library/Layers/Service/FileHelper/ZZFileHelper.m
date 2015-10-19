//
//  ZZFileHelper.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import MediaPlayer;

#import "ZZFileHelper.h"


@implementation ZZFileHelper


#pragma mark - Checks

+ (BOOL)isFileExistsAtURL:(NSURL*)fileURL
{
    BOOL isFileExists = NO;
    if (!ANIsEmpty(fileURL))
    {
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
    }
    return isFileExists;
}

+ (unsigned long long)fileSizeWithURL:(NSURL*)fileURL
{
    if ([self isFileExistsAtURL:fileURL])
    {
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&error];
        if (!error)
        {
            return fileAttributes.fileSize;
        }
    }
    return 0;
}

+ (BOOL)isFileValidWithFileURL:(NSURL*)fileURL
{
    return [self fileSizeWithURL:fileURL] > 0;
}


#pragma mark - File Operations

+ (NSURL*)fileURLInDocumentsDirectoryWithName:(NSString*)fileName
{
    NSURL* url = nil;
    if (!ANIsEmpty(fileName))
    {
        NSURL* documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        url = [documentsURL URLByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"png"]];
    }
    return url;
}

+ (void)deleteFileWithURL:(NSURL*)fileURL
{
    if ([self isFileExistsAtURL:fileURL])
    {
        DebugLog(@"deleteVideoFile");
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        [fm removeItemAtURL:fileURL error:&error];
    }
}


+ (BOOL)isMediaFileCorruptedWithFileUrl:(NSURL*)fileUrl
{
    BOOL isFileCorrupted = YES;
    MPMoviePlayerViewController* playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileUrl];
    MPMoviePlayerController* player = [playerController moviePlayer];
    player.movieSourceType = MPMovieSourceTypeFile;
    [player prepareToPlay];
    
    if (player.loadState == MPMovieLoadStatePlayable)
    {
        isFileCorrupted = NO;
    }
    
    return isFileCorrupted;
}

@end
