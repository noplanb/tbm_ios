//
//  ZZDeleteFriendsFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZDeleteFriendsFeatureEventHandler.h"

@implementation ZZDeleteFriendsFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeDeleteFriendsFeatureUnlocked && ![ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
    {
        [ZZGridActionStoredSettings shared].deleteFriendHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeDeleteFriendUsageHint);
        }
    }
    else
    {
        if(!ANIsEmpty(self.eventHandler))
        {
            [super nextHandlerHandleEvent:event withCompletionBlock:completionBlock];
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(ZZHintsTypeNoHint);
            }
        }
    }
}

@end
