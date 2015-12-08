//
//  ZZSendVideoManager.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSendVideoManager.h"

#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoProcessor.h"
#import "ZZFileHelper.h"

@interface ZZSendVideoManager ()

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation ZZSendVideoManager

- (void)start
{
    if (!self.timer)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
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
        NSURL* fromUrl = [ZZFileHelper fileURlWithFileName:@"IMG_0762" withType:@"MOV"];
        NSURL* toUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:friend.idTbm];
        
        NSError* copyError = nil;
        if([ZZFileHelper copyFileWithUrl:fromUrl toUrl:toUrl error:&copyError])
        {
            NSLog(@"copy file success!!!");
            [[[TBMVideoProcessor alloc] init] processVideoWithUrl:toUrl];
        }
        else
        {
            NSLog(@"copy error!!!");
        }
    }
}

@end
