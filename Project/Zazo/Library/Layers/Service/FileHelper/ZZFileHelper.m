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

+ (uint64_t)loadFreeDiskspaceValue
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject]
                                                                                       error: &error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Storage capacity %llu MiB with %llu MiB free storage available.",
              ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",
              [error domain], (long)[error code]);
    }
    return totalFreeSpace;
}

@end
