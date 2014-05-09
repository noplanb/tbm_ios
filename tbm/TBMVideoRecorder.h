//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
@protocol TBMVideoRecorderDelegate <NSObject>
- (void)didFinishVideoRecordingWithFriendId:(NSString *)friendId;
@end

@interface TBMVideoRecorder : NSObject

@property UIView *previewView;
@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;

+ (NSURL *)outgoingVideoUrlWithFriendId:(NSString *)friendId;

-(instancetype)initWithPreivewView:(UIView *)previewView TBMVideoRecorderDelegate:(id)delegate error:(NSError **)error;
- (void)startRecordingWithFriendId:(NSString *)friendId;
- (void)stopRecording;
- (void)cancelRecording;
@end
