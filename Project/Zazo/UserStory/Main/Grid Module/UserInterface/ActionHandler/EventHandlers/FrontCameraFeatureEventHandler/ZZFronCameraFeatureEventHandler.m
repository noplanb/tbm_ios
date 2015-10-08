//
//  ZZFronCameraFeatureEventHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFronCameraFeatureEventHandler.h"

@implementation ZZFronCameraFeatureEventHandler

- (void)handleEvent:(ZZGridActionEventType)event model:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(ZZHintsType, ZZGridCellViewModel *))completionBlock
{
    if (event == ZZGridActionEventTypeFrontCameraFeatureUnlocked && ![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        [ZZGridActionStoredSettings shared].frontCameraHintWasShown = YES;
        if (completionBlock)
        {
            completionBlock(ZZHintsTypeFrontCameraUsageHint, model);
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
