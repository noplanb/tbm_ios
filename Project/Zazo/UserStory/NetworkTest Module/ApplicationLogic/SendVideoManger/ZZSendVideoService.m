//
//  ZZSendVideoService.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSendVideoService.h"

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

- (NSString *)sendVideo
{
    if (!ANIsEmpty(self.actualFriendID))
    {
        NSURL* fromUrl = [ZZFileHelper fileURlWithFileName:kUploadFileName withType:kUploadFileType];
        NSURL* toUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:self.actualFriendID];
        
        NSError* copyError = nil;
        
        if([ZZFileHelper copyFileWithUrl:fromUrl toUrl:toUrl error:&copyError])
        {
            NSString *marker = [toUrl URLByDeletingPathExtension].lastPathComponent;
            ZZFileTransferMarkerDomainModel* markerModel = [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];

            
            [[[TBMVideoProcessor alloc] init] processVideoWithUrl:toUrl];
            
            return markerModel.videoID;
        }
        else
        {
            NSLog(@"Copy error!!!");
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (NSString *)sendedFriendID
{
    return self.actualFriendID;
}

@end
