//
//  ZZSecretScreenInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenInteractor.h"
#import "ZZStoredSettingsManager.h"
//TODO: temp
#import "TBMDebugData.h"
#import "TBMDispatch.h"

@implementation ZZSecretScreenInteractor

- (void)loadData
{

}



- (void)dispatchData
{
    TBMDebugData *data = [[TBMDebugData alloc] init];
    [TBMDispatch dispatch:[data debugDescription]];
}


- (void)forceCrash
{
    TBMDebugData *data = [[TBMDebugData alloc] init];
    NSMutableString *crashReason = [@"CRASH BUTTON EXCEPTION:" mutableCopy];
    [crashReason appendString:[data debugDescription]];
    NSArray* array = [NSArray array];
    [array objectAtIndex:2];
}

- (void)resetHints
{
    [ZZStoredSettingsManager shared].hintsDidStartRecord = NO;
    [ZZStoredSettingsManager shared].hintsDidStartPlay = NO;
}


#pragma mark - Updating Settings

- (void)updateCustomServerEnpointValueTo:(NSString*)value
{
    [ZZStoredSettingsManager shared].serverURLString = value;
}

- (void)updateDebugStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].debugModeEnabled = isEnabled;
}

- (void)updateServerStateTo:(NSInteger)state
{
    [ZZStoredSettingsManager shared].serverEndpointState = state;
}

@end
