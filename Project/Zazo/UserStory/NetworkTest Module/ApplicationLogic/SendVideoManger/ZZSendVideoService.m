//
//  ZZSendVideoService.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSendVideoService.h"

#import "TBMVideoIDUtils.h"
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
        NSURL* toUrl = [TBMVideoIDUtils generateOutgoingVideoUrlWithFriendID:self.actualFriendID];
        
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

- (NSString *)sendedFriendID
{
    return self.actualFriendID;
}

@end
