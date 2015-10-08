//
//  ZZFeatureEventStrategyRegisteredUser.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyRegisteredUser.h"

@implementation ZZFeatureEventStrategyRegisteredUser

- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
     NSInteger kUnlockFeatureCounterValue = 1;
    NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
    
    BOOL isFeatureEnabled = NO;
    
    if (sendMessageCounter == kUnlockFeatureCounterValue)
    {
        isFeatureEnabled = YES;
    }
    else if (sendMessageCounter == 0)
    {
        sendMessageCounter++;
        [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
        isFeatureEnabled = NO;
    }
    
    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}

@end
