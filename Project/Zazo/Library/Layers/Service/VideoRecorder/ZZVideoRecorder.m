//
//  ZZVideoRecorder.m
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import "ZZVideoRecorder.h"
#import "ZZGridBaseCell.h"
#import "ZZDeviceHandler.h"
#import "ZZGridCollectionCell.h"
#import "ZZGridDomainModel.h"
#import "ZZVideoUtils.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoProcessor.h"
#import "ZZGridCollectionCellViewModel.h"
#import "SCRecorder.h"
#import "TBMAppDelegate+AppSync.h"
#import "ZZGridCenterCell.h"


static NSString* const kVideoProcessorDidFinishProcessing = @"TBMVideoProcessorDidFinishProcessing";
static NSString* const kVideoProcessorDidFail = @"TBMVideoProcessorDidFailProcessing";
//NSString* const kZZVideoProcessorErrorReason = @"Problem processing video";

@interface ZZVideoRecorder () <SCRecorderDelegate>

@property (nonatomic, strong) ZZGridCenterCell* gridCell;
@property (nonatomic, assign) BOOL didCancelRecording;

@property (nonatomic, strong) SCRecorder *recorder;
@property (nonatomic, strong) NSURL* recordVideoUrl;

@end

@implementation ZZVideoRecorder

+ (instancetype)sharedInstance
{
    static ZZVideoRecorder* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self _setupRecorder];
        
    }
    
    return self;
}

- (void) _setupRecorder
{
    self.recorder = [SCRecorder recorder];
    self.recorder.delegate = self;
    
    SCAudioConfiguration *audio = self.recorder.audioConfiguration;
    audio.enabled = YES;
    
    self.recorder.captureSessionPreset = AVCaptureSessionPresetLow;
    self.recorder.device = AVCaptureDevicePositionFront;
    
    SCVideoConfiguration *video = self.recorder.videoConfiguration;
    video.enabled = YES;

    video.scalingMode = AVVideoScalingModeResizeAspectFill;
    self.recorder.device = AVCaptureDevicePositionFront;
    self.recorder.session = [SCRecordSession recordSession];

    [self.recorder startRunning];

}

- (BOOL)isBothCamerasAvailable
{
    return [ZZDeviceHandler isBothCamerasAvailable];
}

- (void)switchToFrontCamera
{
    self.recorder.device = AVCaptureDevicePositionFront;
}

- (void)switchToBackCamera
{
    self.recorder.device = AVCaptureDevicePositionBack;
}



#pragma mark - Public Methods

- (void)updateViewGridCell:(ZZGridBaseCell *)cell
{
    self.gridCell = (ZZGridCenterCell* )cell;
    UIView* videoView = [self.gridCell topView];
    videoView.frame = self.gridCell.frame;
    self.recorder.previewView = videoView;
}


#pragma mark - Start Recording

- (void)startRecordingWithGridCell:(ZZGridCollectionCell*)gridCell
{
    ZZGridCollectionCellViewModel* model = [gridCell model];
    if (model.item.relatedUser && model.item.relatedUser.idTbm)
    {
        [self.gridCell hideChangeCameraButton];
         self.recordVideoUrl = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:model.item.relatedUser];
         [self startRecordingWithVideoUrl:self.recordVideoUrl];
         [self.recorder.session removeAllSegments];
         [self.recorder record];
    }
}

- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl
{
    self.didCancelRecording = NO;
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    [self.gridCell showRecordingOverlay];
}

#pragma mark - Stop Recording

- (void)stopRecording
{
    [self.gridCell showChangeCameraButton];
    [self.gridCell hideRecordingOverlay];
    [self.recorder pause];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error
{
 
    AVAsset *asset = recordSession.assetRepresentingSegments;
    SCAssetExportSession *assetExportSession = [[SCAssetExportSession alloc] initWithAsset:asset];
    assetExportSession.outputUrl = recordSession.outputUrl;
    NSURL* videoPath = recordSession.outputUrl;
    assetExportSession.outputFileType = AVFileTypeMPEG4;
    assetExportSession.videoConfiguration.preset = SCPresetLowQuality;
    assetExportSession.audioConfiguration.preset = SCPresetMediumQuality;

    [assetExportSession exportAsynchronouslyWithCompletionHandler: ^{
        if (assetExportSession.error == nil) {

            NSError* error;
            [[NSFileManager defaultManager] moveItemAtURL:videoPath toURL:self.recordVideoUrl error:&error];

            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFinishProcessing
                                                                object:self
                                                              userInfo:[self notificationUserInfoWithError:nil]];

            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.recordVideoUrl path]])
            {
                NSLog(@"exists");
            }
            else
            {
                NSLog(@"not exitst");
            }

        } else {
            [self handleError:assetExportSession.error dispatch:YES];
        }
    }];
}

- (void)handleError:(NSError *)error dispatch:(BOOL)dispatch
{
    
    [[NSFileManager defaultManager] removeItemAtURL:self.recordVideoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoProcessorDidFail
                                                        object:self
                                                      userInfo:[self notificationUserInfoWithError:error]];
}

- (NSDictionary *)notificationUserInfoWithError:(NSError *)error
{
    if (error == nil)
    {
        return @{@"videoUrl":self.recordVideoUrl};
    }
    else
    {
        return @{@"videoUrl":self.recordVideoUrl, @"error": error};
    }
}


@end
