//
//  ZZSecretDataSource.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZSettingsModel.h"
#import "ZZSecretSwitchCellViewModel.h"
#import "ZZSecretSegmentCellViewModel.h"
#import "NSObject+ANSafeValues.h"

@interface ZZSecretDataSource ()
<
    ZZSecretSwitchCellViewModelDelegate,
    ZZSecretSegmentCellViewModelDelegate,
    ZZSecretScreenTextEditCellViewModelDelegate
>

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

- (void)setupStorageWithViewModel:(ZZSettingsModel*)model;
{
    [self _addUserInfoSectionWithData:model];
    [self _addDetailScreensSection];
    [self _addCustomModesSectionWithData:model];
    [self _addTutorialSectionWithData:model];
    [self _addLoggingSectionsWithData:model];
    [self _addServerInfoSectionWithData:model];
    [self _addResetDataSection];
}

- (void)updateServerCustomURLValue:(NSString *)value
{
    NSIndexPath* segmentCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:ZZSecretSectionServerOptions];
    ZZSecretSegmentCellViewModel* segmentModel = [self.storage objectAtIndexPath:segmentCellIndexPath];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:ZZSecretSectionServerOptions];
    ZZSecretScreenTextEditCellViewModel* model = [self.storage objectAtIndexPath:indexPath];
    model.text = value;
    model.isEnabled = (segmentModel.selectedIndex == 2) ? YES : NO;
    [self.storage reloadItem:model];
}

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case ZZSecretSectionTutorial:
        {
            if (indexPath.row == 0) // reset tutorial hints
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeResetTutorialHints];
            }
            else if (indexPath.row == 1) // feature options
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeFeatureOptions];
            }
        } break;
            
        case ZZSecretSectionDetailScreens:
        {
            if (indexPath.row == 0)
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeLogsScreen];
            }
            else if (indexPath.row == 1)
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeStateScreen];
            }
            else if (indexPath.row == 2)
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeDebugUIScreen];
            }
        } break;
            
        case ZZSecretSectionLoggingOptions:
        {
            if (indexPath.row == 1) // dispatch message
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeDispatchMessage];
            }
        } break;
            
        case ZZSecretSectionResetData:
        {
            if (indexPath.row == 0) //clear all data
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeClearUserData];
            }
            else if (indexPath.row == 1) // delete all dangling files
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeDeleteAllDanglingFiles];
            }
            else if (indexPath.row == 2) // crash application
            {
                [self.delegate actionWithType:ZZSecrectScreenActionsTypeCrashApplication];
            }
        } break;
            
        default: break;
    }
}

- (void)updateEnabledCustomTextFieldStateTo:(BOOL)isEnabled
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:ZZSecretSectionServerOptions];
    ZZSecretScreenTextEditCellViewModel* model = [self.storage objectAtIndexPath:indexPath];
    
    model.isEnabled = isEnabled;
    
}

#pragma mark - Cell Delegates

- (void)viewModel:(ZZSecretSwitchCellViewModel*)viewModel updatedSwitchValueTo:(BOOL)isEnabled
{
    NSIndexPath* indexPath = [self.storage indexPathForItem:viewModel];
    switch (indexPath.section)
    {
        case ZZSecretSectionCustomAppModes:
        {
            [self _customAppModeRowWithIndex:indexPath.row updatedTo:isEnabled];
        }
        break;
            
        case ZZSecretSectionTutorial:
        {
            if (indexPath.row == 2)
            {
                [self.delegate updateEnabledAllFeaturesValueTo:isEnabled];
            }
        } break;
            
        default: break;
    }
}

- (void)viewModel:(ZZSecretSegmentCellViewModel*)model updatedSegmentValueTo:(NSInteger)value
{
    NSIndexPath* indexPath = [self.storage indexPathForItem:model];
    if (indexPath.section == ZZSecretSectionServerOptions)
    {
        [self.delegate updateServerEndpointTypeValueTo:value];
    }
    else if (indexPath.section == ZZSecretSectionLoggingOptions)
    {
        [self.delegate updateShouldUseSDKToLoggingTypeValueTo:value];
    }
}

- (void)viewModel:(ZZSecretScreenTextEditCellViewModel *)viewModel updatedTextValue:(NSString *)textValue
{
    [self.delegate updateCustomServerURLValueTo:textValue];
}


#pragma mark - Private

- (void)_addUserInfoSectionWithData:(ZZSettingsModel*)model
{
     NSArray* items = @[[ZZSecretValueCellViewModel viewModelWithTitle:@"Version"
                                                               details:[NSObject an_safeString:model.version]],
                        [ZZSecretValueCellViewModel viewModelWithTitle:@"First Name"
                                                               details:[NSObject an_safeString:model.firstName]],
                        [ZZSecretValueCellViewModel viewModelWithTitle:@"Last Name"
                                                               details:[NSObject an_safeString:model.lastName]],
                        [ZZSecretValueCellViewModel viewModelWithTitle:@"Phone number"
                                                               details:[NSObject an_safeString:model.phoneNumber]]];
    [self.storage addItems:items toSection:ZZSecretSectionUserInfo];
    [self.storage setSectionHeaderModel:@"User Info" forSectionIndex:ZZSecretSectionUserInfo];
}

- (void)_addDetailScreensSection
{
    NSArray* items = @[[ZZSecretValueCellViewModel viewModelWithTitle:@"Logs Screen"
                                                              details:nil],
                       [ZZSecretValueCellViewModel viewModelWithTitle:@"State Screen"
                                                              details:nil],
                       [ZZSecretValueCellViewModel viewModelWithTitle:@"Debug UI Screen"
                                                              details:nil]];
    [self.storage addItems:items toSection:ZZSecretSectionDetailScreens];
    [self.storage setSectionHeaderModel:@"Debug Screens" forSectionIndex:ZZSecretSectionDetailScreens];
}

- (void)_addCustomModesSectionWithData:(ZZSettingsModel*)model
{
    NSArray* models = @[[self _switchModelWithTitle:@"Debug Mode" state:model.isDebugEnabled]];

    [self.storage addItems:models toSection:ZZSecretSectionCustomAppModes];
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.customization-header.title.text", nil)
                        forSectionIndex:ZZSecretSectionCustomAppModes];
}

- (void)_addTutorialSectionWithData:(ZZSettingsModel*)model
{
    NSArray* items = @[[ZZSecretValueCellViewModel viewModelWithTitle:@"Reset tutorial hints" details:nil],
                       [ZZSecretValueCellViewModel viewModelWithTitle:@"Feature options" details:nil],
                       [self _switchModelWithTitle:@"Enable all features" state:model.enableAllFeatures]];
   
    [self.storage addItems:items toSection:ZZSecretSectionTutorial];
    [self.storage setSectionHeaderModel:NSLocalizedString(@"secret-controller.tutorial-header.title.text", nil)
                        forSectionIndex:ZZSecretSectionTutorial];
}

- (void)_addLoggingSectionsWithData:(ZZSettingsModel*)model
{
    NSArray* items = @[NSLocalizedString(@"secret-controller.server.segment-control.title", nil),
                       NSLocalizedString(@"secret-controller.rollbar.segment-control.title", nil)];
    
    ZZSecretSegmentCellViewModel* rollBar = [ZZSecretSegmentCellViewModel viewModelWithTitles:items];
    rollBar.delegate = self;
    
    ZZSecretValueCellViewModel* dispatch = [ZZSecretValueCellViewModel viewModelWithTitle:@"Send dispatch message" details:nil];
    
    [self.storage addItems:@[rollBar, dispatch] toSection:ZZSecretSectionLoggingOptions];
    [self.storage setSectionHeaderModel:@"Logging options" // TODO:
                        forSectionIndex:ZZSecretSectionLoggingOptions];
}

- (void)_addServerInfoSectionWithData:(ZZSettingsModel*)model
{
    NSArray* serverItems = @[NSLocalizedString(@"secret-controller.prodserver.title", nil),
                             NSLocalizedString(@"secret-controller.stageserver.title", nil),
                             NSLocalizedString(@"secret-controller.customserver.title", nil)];
    ZZSecretSegmentCellViewModel* server = [ZZSecretSegmentCellViewModel viewModelWithTitles:serverItems];
    server.selectedIndex = model.serverIndex;
    server.delegate = self;
    
    ZZSecretScreenTextEditCellViewModel* textEdit = [ZZSecretScreenTextEditCellViewModel new];
    textEdit.text = model.serverURLString;
    textEdit.isEnabled = (model.serverIndex == 2);
    
    [self.storage addItems:@[server, textEdit] toSection:ZZSecretSectionServerOptions];
    [self.storage setSectionHeaderModel:@"Server options" // TODO:
                        forSectionIndex:ZZSecretSectionServerOptions];
}

- (void)_addResetDataSection
{
    NSArray* items = @[[ZZSecretValueCellViewModel viewModelWithTitle:@"Clear user data (friends, videos)" details:nil],
                       [ZZSecretValueCellViewModel viewModelWithTitle:@"Delete all dangling files" details:nil],
                       [ZZSecretValueCellViewModel viewModelWithTitle:@"Crash application" details:nil]];
    
    [self.storage addItems:items toSection:ZZSecretSectionResetData];
    [self.storage setSectionHeaderModel:@"Reset Data" // TODO:
                        forSectionIndex:ZZSecretSectionResetData];
}

- (ZZSecretSwitchCellViewModel*)_switchModelWithTitle:(NSString*)title state:(BOOL)isEnabled
{
    ZZSecretSwitchCellViewModel* model = [ZZSecretSwitchCellViewModel new];
    model.title = title;
    model.switchState = isEnabled;
    model.delegate = self;
    return model;
}

- (void)_customAppModeRowWithIndex:(NSInteger)index updatedTo:(BOOL)value
{
    switch (index)
    {
        case 0:
        {
            [self.delegate updateDebugModeValueTo:value];
        } break;
            
        default: break;
    }
}

@end
