//
//  ZZFeatureEventStrategyBase.h
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ZZGridActionStoredSettings.h"

#pragma mark - Use both camera keys

static NSString* const kFriendIdDefaultKey = @"userIdDefaultKey";
static NSString* const kSendMessageCounterKey = @"sendMessageCounterKey";

@interface ZZFeatureEventStrategyBase : NSObject

- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleAbortRecordingFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
@end
