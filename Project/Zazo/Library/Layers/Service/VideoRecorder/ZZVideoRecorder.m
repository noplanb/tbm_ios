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
#import "ZZGridCellViewModel.h"

@interface ZZVideoRecorder () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) ZZGridBaseCell* gridCell;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureInput *videoInput;
@property (nonatomic, strong) AVCaptureInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureOutput;
@property (nonatomic, assign) BOOL didCancelRecording;

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
        [self _addObservers];
        [self _initCaptureSession];
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(self.sessionQueue, ^{
            [self _initVideoInput];
            [self _initAudioInput];
            [self _initCaptureOutput];
            [self.captureSession setUsesApplicationAudioSession:YES];
            [self.captureSession setAutomaticallyConfiguresApplicationAudioSession:NO];
            [self.captureSession startRunning];
        });
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (void)_initCaptureSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow])
    {
        self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
    }
}

- (void)_initVideoInput
{
    NSError *error;
    self.videoInput = [ZZDeviceHandler getAvailableFrontVideoInputWithError:&error];
    if (error)
    {
        // TODO:
    }
    [self.captureSession addInput:self.videoInput];
}

- (void)_initAudioInput
{
    NSError *error;
    self.audioInput = [ZZDeviceHandler getAudioInputWithError:&error];
    if (error)
    {
        //TODO:
    }
    
    [self.captureSession addInput:self.audioInput];
}

- (void)_initCaptureOutput {
    self.captureOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.captureOutput]) {
        [self.captureSession addOutput:self.captureOutput];
    }
}

- (void)_updateGridCellWithCaptureSession
{
    [self.gridCell setupWithCaptureSession:self.captureSession];
}

#pragma mark - Public Methods


- (void)updateViewGridCell:(ZZGridBaseCell *)cell
{
    self.gridCell = cell;
    [self _updateGridCellWithCaptureSession];
}

- (void)startRunning
{
    dispatch_async(self.sessionQueue, ^{
        if (self.captureSession)
        {
            [self.captureSession startRunning];
        }
    });
}

#pragma mark - Start Recording

- (void)startRecordingWithGridCell:(ZZGridCollectionCell*)gridCell
{
    ZZGridCellViewModel* model = [gridCell model];
    if (model.domainModel.relatedUser && model.domainModel.relatedUser.idTbm)
    {
        NSURL* videoUrl = [ZZVideoUtils generateOutgoingVideoUrlWithFriend:model.domainModel.relatedUser];
        [self startRecordingWithVideoUrl:videoUrl];
    }
}

- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl
{
    self.didCancelRecording = NO;
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    [self.gridCell showRecordingOverlay];
    [self.captureOutput startRecordingToOutputFileURL:videoUrl recordingDelegate:self];
}

#pragma mark - Stop Recording

- (void)stopRecording
{
    if (!self.captureOutput.isRecording)
    {
        // note that in some error cases when audiosession was connected stop recording would be called and isRecording == NO.  We will not get a didFinsishRecording in this case. AudioSession needs to observe videoRecorderDidFail for these condtitions although we should ensure they never occur.
//        NSString *description = @"VideoRecorder@stopRecording called but not recording. This should never happen";
//        NSError *error = [self videoRecorderError:description reason:@"Problem recording video"];
//        [self handleError:error];
    }
    [self.captureOutput stopRecording];
    [self.gridCell hideRecordingOverlay];
}

- (BOOL)cancelRecording
{
    self.didCancelRecording = YES;
    [self stopRecording];
    return [self.captureOutput isRecording];
}

- (void)dispose
{
    dispatch_sync(self.sessionQueue, ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.captureSession stopRunning];
    });
}

- (BOOL)isRecording
{
    return [self.captureOutput isRecording];
}

#pragma mark - Observer part

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_captureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_captureSessionDidStartRunningNotification:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_captureSessionDidStopRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_captureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_captureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
}

- (void)_captureSessionRuntimeErrorNotification:(NSNotification *)notification
{
    [self startRunning]; //TODO: check this
    
}
- (void)_captureSessionDidStartRunningNotification:(NSNotification *)notification
{
    [self startRunning];
}

- (void)_captureSessionDidStopRunningNotification:(NSNotification *)notification
{
    
}
- (void)_captureSessionWasInterruptedNotification:(NSNotification *)notification
{
    
}
- (void)_captureSessionInterruptionEndedNotification:(NSNotification *)notification
{
    
}

#pragma mark Recording Delegate methods

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                                                               fromConnections:(NSArray *)connections
                                                                                         error:(NSError *)error
{
    
    // TODO: add error handler
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidFinishRecording
//                                                        object:self
//                                                      userInfo:@{@"videoUrl": outputFileURL}];
    
//    BOOL abort = NO;
//    
//    if (self.didCancelRecording){
//        OB_INFO(@"didCancelRecordingToOutputFileAtURL:%@ error:%@", outputFileURL, error);
//        [[NSNotificationCenter defaultCenter] postNotificationName:TBMVideoRecorderDidCancelRecording
//                                                            object:self
//                                                          userInfo:@{@"videoUrl": outputFileURL}];
//        abort = YES;
//        
//    } else if (error != nil){
//        NSError *newError = [NSError errorWithError:error reason:@"Problem recording video"];
//        [self handleError:newError];
//        abort = YES;
//        
//    } else if ([self videoTooShort:outputFileURL]){
//        OB_INFO(@"VideoRecorder#videoTooShort aborting");
//        NSError *error = [self videoRecorderError:@"Video too short" reason:@"Too short"];
//        [self handleError:error dispatch:NO];
//        abort = YES;
//    }
//    
//    if (abort){
//        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
//        return;
//    }
//    
//    OB_INFO(@"didFinishRecording success friend:%@ videoId:%@",
//            [TBMVideoIdUtils friendWithOutgoingVideoUrl:outputFileURL].firstName,
//            [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:outputFileURL]);
//    
    [[[ZZVideoProcessor alloc] init] processVideoWithUrl:outputFileURL];
}



@end
