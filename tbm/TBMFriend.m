//
//  Friend.m
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "TBMConfig.h"

@implementation TBMFriend

@dynamic firstName;
@dynamic lastName;
@dynamic outgoingVideoStatus;
@dynamic incomingVideoStatus;
@dynamic viewIndex;
@dynamic uploadRetryCount;
@dynamic idTbm;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext
{
    return [[TBMFriend appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:@"TBMFriend" inManagedObjectContext:[TBMFriend managedObjectContext]];
}

//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMFriend entityDescription]];
    return request;
}

+ (NSArray *)all{
    NSError *error;
    return [[TBMFriend managedObjectContext] executeFetchRequest:[TBMFriend fetchRequest] error:&error];
}

+ (instancetype)findWithId:(NSString *)idTbm{
    return [self findWithAttributeKey:@"idTbm" value:idTbm];
}

+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex{
    return [self findWithAttributeKey:@"viewIndex" value:viewIndex];
}

+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    NSFetchRequest *request = [TBMFriend fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *friends = [[TBMFriend managedObjectContext] executeFetchRequest:request error:&error];
    return [friends lastObject];
}

+ (NSUInteger)count{
    return [[TBMFriend all] count];
}

//-------------------
// Create and destroy
//-------------------
+ (id)newWithId:(NSString *)idTbm
{
    TBMFriend *friend = (TBMFriend *)[[NSManagedObject alloc] initWithEntity:[TBMFriend entityDescription] insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
    friend.idTbm = idTbm;
    return friend;
}

+ (NSUInteger)destroyAll
{
    NSArray *allFriends = [TBMFriend all];
    NSUInteger count = [allFriends count];
    for (TBMFriend *friend in allFriends) {
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
    return count;
}

+ (void)destroyWithId:(NSString *)idTbm
{
    TBMFriend *friend = [TBMFriend findWithId:idTbm];
    if ( friend != nil ){
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
}

+ (void)saveAll{
    [[TBMFriend appDelegate] saveContext];
}


//-----------------
// Instance methods
//-----------------

// Video URL stuff
- (NSURL *)incomingVideoUrl{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend%@", self.idTbm];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

- (NSString *)incomingVideoPath{
    return [self incomingVideoUrl].path;
}

- (BOOL)incomingVideoFileExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self incomingVideoPath]];
}

- (unsigned long long)incomingVideoFileSize{
    if (![self incomingVideoFileSize])
        return 0;
    
    NSError *error;
    NSDictionary *fa = [[NSFileManager defaultManager] attributesOfItemAtPath:[self incomingVideoPath] error:&error];
    if (error)
        return 0;
    
    return fa.fileSize;
}

- (BOOL) hasValidIncomingVideoFile{
    return [self incomingVideoFileSize] > 0;
}

// Thumb URL stuff
- (NSURL *)thumbUrl{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend%@", self.idTbm];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

- (NSString *)thumbPath{
    return [self thumbUrl].path;
}

- (BOOL)hasThumb{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self thumbPath]];
}

- (void)generateThumb{
    if (![self hasValidIncomingVideoFile])
        return;
    
    AVAsset *asset = [AVAsset assetWithURL:[self incomingVideoUrl]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrl] atomically:YES];
}

- (NSURL *)thumbUrlOrThumbMissingUrl{
    if ([self hasThumb]) {
        return [self thumbUrl];
    } else {
        return [TBMConfig thumbMissingUrl];
    }
}

- (UIImage *)thumbImageOrThumbMissingImage{
    return [UIImage imageWithContentsOfFile:[self thumbUrlOrThumbMissingUrl].path];
}

// Upload stuff
- (void)setRetryCountWithInteger:(NSInteger)count{
    self.uploadRetryCount = [NSNumber numberWithInteger:count];
}

- (NSInteger)getRetryCount{
    return [self.uploadRetryCount integerValue];
}

- (void)incrementRetryCount{
    NSInteger count = [self getRetryCount] + 1;
    [self setRetryCountWithInteger:count];
}
@end
