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

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature; //this property should load from data provider

@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

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

- (void)welcomeZazoSentSuccessfully // welcome zazo - message to user that we invited, and no other messages from this friend was not received
{
    self.lastUnlockedFeature++;
    // store new value in data provider
    [self.delegate unlockFeature:self.lastUnlockedFeature]; // show message, unlock UI
    //
}

- (void)dismissedHintWithType:(ZZGridActionEventType)type
{

}

@end
