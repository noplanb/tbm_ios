//
//  ZZInviteSomeoneElseEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZInviteSomeoneElseEventHandler.h"

@implementation ZZInviteSomeoneElseEventHandler

- (void)handleEvent:(ZZGridActionEventType)event
              model:(ZZGridCellViewModel *)model
withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeSentZazo && ![ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown)
    {
        [ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeInviteSomeElseHint, model);
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
