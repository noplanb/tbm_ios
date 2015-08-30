//
//  ZZSecretDataSource.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZSettingsViewModel.h"
#import "ZZSecretButtonCellViewModel.h"
#import "ZZSecretSwitchCellViewModel.h"
#import "ZZSecretSwitchServerCellViewModel.h"
#import "ZZSecretSegmentControlCellViewModel.h"

@interface ZZSecretDataSource () <ZZSecretButtonCellViewModelDelegate, ZZSecretSwitchCellViewModelDelegate>

@end

@implementation ZZSecretDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
    }
    return self;
}

- (void)setupStorageWithViewModel:(ZZSettingsViewModel *)model;
{
    [self _addSectionWithModel:model];
}

#pragma mark - Private

//"secret-controller.debug-header.title.text" = "Debug options";
//"secret-controller.general-header.title.text" = "General";
//"secret-controller.customization-header.title.text" = "Customization";
//"secret-controller.registration-header.title.text" = "Registration options";
//"secret-controller.tutorial-header.title.text" = "Tutorial";


- (void)_addSectionWithModel:(ZZSettingsViewModel *)model
{
    [self _setupGeneralSectionWithModel:model];
    [self _setupGeneralSectionWithDebugModeStatus:model.item.isDebugEnabled];
    [self _setupCustomizationSectionWithModel:model];
    [self _setupRegistrationOptionsSectionWithModel:model];
    [self _setupTutorialSectionWithModel:model];
}

- (void)_setupGeneralSectionWithModel:(ZZSettingsViewModel *)model
{
    ZZSecretButtonCellViewModel *versionModel = [ZZSecretButtonCellViewModel new];
    versionModel.title = [NSString stringWithFormat:@"Version: %@", model.item.version];
    versionModel.type = ZZSecretButtonCellTypeNone;
    
    ZZSecretButtonCellViewModel *userModel = [ZZSecretButtonCellViewModel new];
    userModel.title = [NSString stringWithFormat:@"Username: %@ %@", model.item.firstName, model.item.lastName];
    userModel.type = ZZSecretButtonCellTypeNone;
    
    ZZSecretButtonCellViewModel *phoneNumberModel = [ZZSecretButtonCellViewModel new];
    phoneNumberModel.title = [NSString stringWithFormat:@"Phone number: %@", model.item.phoneNumber];
    phoneNumberModel.type = ZZSecretButtonCellTypeNone;
    
    ZZSecretButtonCellViewModel *dispatchButtonModel = [ZZSecretButtonCellViewModel new];
    dispatchButtonModel.type = ZZSecretButtonCellTypeDispatchButton;
    dispatchButtonModel.delegate = self;
    
    ZZSecretButtonCellViewModel *clearModel = [ZZSecretButtonCellViewModel new];
    clearModel.type = ZZSecretButtonCellTypeClearData;
    clearModel.title = @"Clear user data (friends, videos)";
    clearModel.delegate = self;
    
    [self.storage addItem:versionModel toSection:ZZSecretSectionGeneral];
    [self.storage addItem:userModel toSection:ZZSecretSectionGeneral];
    [self.storage addItem:phoneNumberModel toSection:ZZSecretSectionGeneral];
    [self.storage addItem:dispatchButtonModel toSection:ZZSecretSectionGeneral];
    [self.storage addItem:clearModel toSection:ZZSecretSectionGeneral];
    
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.general-header.title.text", nil) forSectionIndex:ZZSecretSectionGeneral];
}

- (void)_setupGeneralSectionWithDebugModeStatus:(BOOL)status
{
    ZZSecretSwitchCellViewModel* debugSwitch = [ZZSecretSwitchCellViewModel new];
    debugSwitch.type = ZZSecretSwitchCellTypeDebug;
    debugSwitch.switchState = status;
    debugSwitch.title = @"Debug mode";
    debugSwitch.delegate = self;
    
    [self.storage addItem:debugSwitch toSection:ZZSecretSectionDebugOptions];
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.debug-header.title.text", nil) forSectionIndex:ZZSecretSectionDebugOptions];
}

- (void)_setupCustomizationSectionWithModel:(ZZSettingsViewModel *)model
{
    ZZSecretSwitchCellViewModel* rearCameraSwitch = [ZZSecretSwitchCellViewModel new];
    rearCameraSwitch.type = ZZSecretSwitchCellTypeUseRearCamera;
    rearCameraSwitch.switchState = model.item.useRearCamera;
    rearCameraSwitch.title = @"Use rear camera";
    rearCameraSwitch.delegate = self;
    
    ZZSecretSwitchCellViewModel* sendBrokenVideoSwitch = [ZZSecretSwitchCellViewModel new];
    sendBrokenVideoSwitch.type = ZZSecretSwitchCellTypeSendBrokenVideo;
    sendBrokenVideoSwitch.switchState = model.item.sendBrokenVideo;
    sendBrokenVideoSwitch.title = @"Send broken video";
    sendBrokenVideoSwitch.delegate = self;
    
    [self.storage addItem:rearCameraSwitch toSection:ZZSecretSectionCustomization];
    [self.storage addItem:sendBrokenVideoSwitch toSection:ZZSecretSectionCustomization];
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.customization-header.title.text", nil) forSectionIndex:ZZSecretSectionCustomization];
}

- (void)_setupRegistrationOptionsSectionWithModel:(ZZSettingsViewModel *)model
{
    ZZSecretSegmentControlCellViewModel *segmentModel = [ZZSecretSegmentControlCellViewModel new];
    
    ZZSecretSwitchCellViewModel* forceSMSSwitch = [ZZSecretSwitchCellViewModel new];
    forceSMSSwitch.type = ZZSecretSwitchCellTypeForceRegSMS;
    forceSMSSwitch.switchState = model.item.forceRegSMS;
    forceSMSSwitch.title = @"Force SMS during registration";
    forceSMSSwitch.delegate = self;
    
    ZZSecretSwitchCellViewModel* forceCallSwitch = [ZZSecretSwitchCellViewModel new];
    forceCallSwitch.type = ZZSecretSwitchCellTypeForceRegCall;
    forceCallSwitch.switchState = model.item.forceRegCall;
    forceCallSwitch.title = @"Force Call during registration";
    forceCallSwitch.delegate = self;
    
    ZZSecretSwitchServerCellViewModel *swithServerModel = [ZZSecretSwitchServerCellViewModel new];
    
    [self.storage addItem:segmentModel toSection:ZZSecretSectionRegistrationOptions];
    [self.storage addItem:forceSMSSwitch toSection:ZZSecretSectionRegistrationOptions];
    [self.storage addItem:forceCallSwitch toSection:ZZSecretSectionRegistrationOptions];
    [self.storage addItem:swithServerModel toSection:ZZSecretSectionRegistrationOptions];
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.registration-header.title.text", nil) forSectionIndex:ZZSecretSectionRegistrationOptions];
}

- (void)_setupTutorialSectionWithModel:(ZZSettingsViewModel *)model
{
    ZZSecretButtonCellViewModel *resetTutorialHints = [ZZSecretButtonCellViewModel new];
    resetTutorialHints.type = ZZSecretButtonCellTypeResetTutorial;
    resetTutorialHints.title = @"Reset tutorial hints";
    resetTutorialHints.delegate = self;
    
    ZZSecretButtonCellViewModel *featureOptions = [ZZSecretButtonCellViewModel new];
    featureOptions.type = ZZSecretButtonCellTypeFeatureOptions;
    featureOptions.title = @"Feature options";
    featureOptions.delegate = self;
    
    ZZSecretSwitchCellViewModel* enableAllFuturesSwitch = [ZZSecretSwitchCellViewModel new];
    enableAllFuturesSwitch.type = ZZSecretSwitchCellTypeEnableAllFeatures;
    enableAllFuturesSwitch.switchState = model.item.enableAllFeatures;
    enableAllFuturesSwitch.title = @"Enable all futures";
    enableAllFuturesSwitch.delegate = self;
    
    [self.storage addItem:resetTutorialHints toSection:ZZSecretSectionTutorial];
    [self.storage addItem:featureOptions toSection:ZZSecretSectionTutorial];
    [self.storage addItem:enableAllFuturesSwitch toSection:ZZSecretSectionTutorial];
    
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.tutorial-header.title.text", nil) forSectionIndex:ZZSecretSectionTutorial];
}

#pragma mark - ZZSecretButtonCellViewModelDelegate

- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type
{
    [self.delegate buttonSelectedWithType:type];
}

#pragma mark - ZZSecretSwitchCellViewModelDelegate

- (void)switchValueChangedForType:(ZZSecretSwitchCellType)type
{
    [self.delegate switchValueChangedForType:type];
}

@end
