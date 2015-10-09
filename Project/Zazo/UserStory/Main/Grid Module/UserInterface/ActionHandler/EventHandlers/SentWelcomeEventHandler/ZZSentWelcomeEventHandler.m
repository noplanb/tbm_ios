//
//  ZZSentWelcomeEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSentWelcomeEventHandler.h"

static NSString* kLaunchTimeCounterKey = @"LaunchTimeCounterKey";

@implementation ZZSentWelcomeEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeFriendDidInvited &&
        ![ZZGridActionStoredSettings shared].welcomeHintWasShown)
    {
        
        NSInteger launchCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchTimeCounterKey];
        
        ZZHintsType type = ZZHintsTypeNoHint;
        
        if (launchCounter < 6)
        {
            launchCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:launchCounter forKey:kLaunchTimeCounterKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            type = ZZHintsTypeSendWelcomeHint;
            if (![model.item.relatedUser hasApp])
            {
                type = ZZHintsTypeSendWelcomeHintForFriendWithoutApp;
            }
            
        }
        else if (launchCounter == 6)
        {
            [ZZGridActionStoredSettings shared].welcomeHintWasShown = YES;
        }
        
        if (completionBlock)
        {
            completionBlock(type, model);
        }
    }
    else
    {
        if(!ANIsEmpty(self.eventHandler))
        {
            [super nextHandlerHandleEvent:event model:model withCompletionBlock:completionBlock];
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeNoHint, model);
            }
        }
    }
}

@end
