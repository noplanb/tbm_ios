//
//  ZZGridActionHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandler.h"
#import "ZZGridActionDataProvider.h"

@interface ZZGridActionHandler ()

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature;

@end

@implementation ZZGridActionHandler

- (void)handleEvent:(ZZGridActionEventType)event
{
    switch (event)
    {
        case ZZGridActionEventTypeTest:
        {
            
        } break;
        default: break;
    }
}

- (void)welcomeZazoSentSuccessfully
{
    self.lastUnlockedFeature++;
    // store in data provider
    
    []
    [self.delegate unlockFeature:self.lastUnlockedFeature]; // show message, unlock UI
}

@end
