//
//  ZZSendVideoService.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSendVideoService.h"

#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoProcessor.h"
#import "ZZFileHelper.h"
#import "ZZFriendDataProvider.h"

static NSString* const kUploadFileName = @"IMG_0764";
static NSString* const kUploadFileType = @"MOV";

@interface ZZSendVideoService ()

@property (nonatomic, strong) NSString* actualFriendID;

@end


@implementation ZZSendVideoService

- (void)configureActionFriendID:(NSString *)friendID
{
    self.actualFriendID = friendID;
}

- (void)sendVideo
{
    if (!ANIsEmpty(self.actualFriendID))
    {
        NSURL* fromUrl = [ZZFileHelper fileURlWithFileName:kUploadFileName withType:kUploadFileType];
        NSURL* toUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:self.actualFriendID];
        
        NSError* copyError = nil;
        
        if([ZZFileHelper copyFileWithUrl:fromUrl toUrl:toUrl error:&copyError])
        {
            [[[TBMVideoProcessor alloc] init] processVideoWithUrl:toUrl];
        }
        else
        {
            NSLog(@"Copy error!!!");
        }
    }
}

- (void)resetRetries
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:self.actualFriendID];
    friend.uploadRetryCount = @(0);
    [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
}

@end
