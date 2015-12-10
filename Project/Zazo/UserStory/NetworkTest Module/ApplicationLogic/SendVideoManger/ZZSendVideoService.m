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

static CGFloat const kSendVideoInterval = 3.0;
static NSString* const kUploadFileName = @"IMG_0764";
static NSString* const kUploadFileType = @"MOV";

@interface ZZSendVideoService ()

@property (nonatomic, strong) NSTimer* timer;

@end


@implementation ZZSendVideoService

- (void)start
{
    if (!self.timer)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kSendVideoInterval
                                                      target:self
                                                    selector:@selector(_sendVideo)
                                                    userInfo:nil repeats:YES];
    }
}

- (void)stop
{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = nil;
}


- (void)_sendVideo
{
    TBMFriend* friend = [[TBMFriend MR_findAll] firstObject];
    if (!ANIsEmpty(friend))
    {
        NSURL* fromUrl = [ZZFileHelper fileURlWithFileName:kUploadFileName withType:kUploadFileType];
        NSURL* toUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:friend.idTbm];
        
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

- (void)dealloc
{
    [self stop];
}



@end
