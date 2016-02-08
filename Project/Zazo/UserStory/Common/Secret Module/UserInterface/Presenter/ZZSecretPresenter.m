//
//  ZZSecretPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretPresenter.h"
#import "ZZSecretDataSource.h"

@interface ZZSecretPresenter ()<ZZSecretDataSourceDelegate>

@property (nonatomic, strong) ZZSecretDataSource* tableDataSource;

@end

@implementation ZZSecretPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.tableDataSource = [ZZSecretDataSource new];
        self.tableDataSource.delegate = self;
    }
    return self;
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface updateDataSource:self.tableDataSource];
    
    [self.interactor loadData];
}

#pragma mark - Output

- (void)dataLoaded:(ZZDebugSettingsStateDomainModel *)model;
{
    [self.tableDataSource setupStorageWithViewModel:model];
}

- (void)serverEndpointValueUpdatedTo:(NSString *)value
{
    [self.tableDataSource updateServerCustomURLValue:value];
}

#pragma mark - Module Interface

- (void)dismissController
{
    [self.wireframe dismissSecretController];
}

#pragma mark - ZZSecretDataSourceDelegate

- (void)actionWithType:(ZZSecrectScreenActionsType)type
{
    //TODO: show message that action done
    switch (type)
    {
        case ZZSecrectScreenActionsTypeResetTutorialHints:
        {
            [self.interactor resetHints];
        } break;
        case ZZSecrectScreenActionsTypeFeatureOptions:
        {
//            [self.interactor featu] // TODO: check Maxim code
        } break;
        case ZZSecretScreenActionsTypeEnableAllFeatures:
        {
            [self.interactor updateAllFeaturesToEnabled];
        } break;
        case ZZSecrectScreenActionsTypeDispatchMessage:
        {
            [self.interactor dispatchData];
        } break;
        case ZZSecrectScreenActionsTypeClearUserData:
        {
            [self.interactor removeAllUserData];
        } break;
        case ZZSecrectScreenActionsTypeDeleteAllDanglingFiles:
        {
            [self.interactor removeAllDanglingFiles];
        } break;
        case ZZSecrectScreenActionsTypeCrashApplication:
        {
            [self.interactor forceCrash];
        } break;
        case ZZSecrectScreenActionsTypeLogsScreen:
        {
            [self.wireframe presentLogsController];
        } break;
        case ZZSecrectScreenActionsTypeStateScreen:
        {
            [self.wireframe presentStateController];
        } break;
        case ZZSecrectScreenActionsTypeDebugUIScreen:
        {
            [self.wireframe presentDebugController];
        } break;
        case ZZSecretSectionShouldDuplicateNextUpload:
        {
            [self.interactor shouldDuplicateNextUpload];
        } break;
            
        default: break;
    }
}

- (void)updateDebugModeValueTo:(BOOL)isEnabled
{
    [self.interactor updateDebugStateTo:isEnabled];
}

- (void)updateShouldUseSDKToLoggingTypeValueTo:(BOOL)value
{
    [self.interactor updateShouldUserSDKForLogging:value];
}

- (void)updateServerEndpointTypeValueTo:(NSInteger)value
{
    [self.tableDataSource updateEnabledCustomTextFieldStateTo:(value == 2)];
    [self.interactor updateServerStateTo:value];
}

- (void)updateCustomServerURLValueTo:(NSString*)value
{
    [self.interactor updateCustomServerEnpointValueTo:value];
}

- (void)updatePushNotificationState:(BOOL)state
{
    [self.interactor updatePushNotificationStateTo:state];
}

- (void)updateIncorrectFileSizeState:(BOOL)state
{
    [self.interactor updateIncorrectFileSizeStateTo:state];
}

@end
