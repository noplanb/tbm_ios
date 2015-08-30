//
//  ZZSecretInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretInteractor.h"
#import "ZZSettingsModel.h"
#import "ZZStoredSettingsManager.h"
#import "TBMUser.h"
#import "ZZSecretEnums.h"

@implementation ZZSecretInteractor

- (void)loadData
{
    ZZSettingsModel* model = [self _generateDebugSettingsModel];
    [self.output dataLoaded:model];
}

- (void)changeValueForType:(ZZSecretSwitchCellType)type
{
    
}

- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type
{
    
}

#pragma mark - Private

- (ZZSettingsModel*)_generateSettingsModel
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];
    ZZSettingsModel* model = [ZZSettingsModel new];
    model.isDebugEnabled = manager.debugModeEnabled;
    model.serverURLString = manager.serverURLString;
    model.serverIndex = manager.serverEndpointState;
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    model.version = [NSString stringWithFormat:@"%@(%@)", [NSObject an_safeString:version], [NSObject an_safeString:buildNumber]];
    
    TBMUser *user = [TBMUser getUser];
    model.firstName = user.firstName;
    model.lastName = user.lastName;
    model.phoneNumber = user.mobileNumber;
    
    return model;
}

- (ZZSettingsModel*)_generateDebugSettingsModel
{
    ZZSettingsModel* model = [ZZSettingsModel new];
    model.isDebugEnabled = YES;
    model.serverURLString = @"staging.zazoapp.com";
    model.serverIndex = 1;
    model.version = @"1.01";

    model.firstName = @"Anoda";
    model.lastName = @"Mobi";
    model.phoneNumber = @"0 800 777 77 77";
    
    model.sendBrokenVideo = YES;
    model.useRearCamera = YES;
    
    return model;
}

@end
