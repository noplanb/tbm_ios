//
//  ZZFronCameraFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFronCameraFeatureEventHandler.h"

@implementation ZZFronCameraFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event withCompletionBlock:(void (^)(ZZHintsType type))completionBlock
{
    if (event == ZZGridActionEventTypeFrontCameraFeatureUnlocked && ![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        [ZZGridActionStoredSettings shared].frontCameraHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeFrontCameraUsageHint);
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
