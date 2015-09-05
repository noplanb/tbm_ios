//
//  ZZGridDataSource.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZGridCellViewModel.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZFriendDomainModel.h"

static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridDataSource () <ZZGridCellViewModellDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* selectedCellViewModel;

@end

@implementation ZZGridDataSource

- (instancetype)init
{
    if (self = [super init])
    {
        self.storage = [ANMemoryStorage new];
    }
    return self;
}

- (void)setupWithModels:(NSArray *)models
{
    models = [[models.rac_sequence map:^id(ZZGridDomainModel* value) {
        
        ZZGridCellViewModel* viewModel = [ZZGridCellViewModel new];
        viewModel.item = value;
        viewModel.delegate = self;
        return viewModel;
    }] array];
    
    [self.storage addItems:models];
    
    ZZGridCenterCellViewModel* model = [ZZGridCenterCellViewModel new];
    [self.storage addItem:model atIndexPath:[self _centerCellIndexPath]];
}

- (void)selectedViewModelUpdatedWithItem:(ZZGridDomainModel*)model
{
    self.selectedCellViewModel.item = model;
    [self.storage reloadItem:self.selectedCellViewModel];
}

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedCellViewModel = [self.storage objectAtIndexPath:indexPath];
    [self.delegate itemSelectedWithModel:self.selectedCellViewModel];
}


#pragma mark - ViewModel Delegate

- (void)startRecordingWithView:(id)view
{
//    [[self centerCell] showRecordingOverlay]; // TODO:
    
    [self.delegate recordingStateUpdateWithView:view toState:YES];
}

- (void)stopRecording
{
//    [[self centerCell] hideRecordingOverlay]; //TODO:
    [self.delegate recordingStateUpdateWithView:nil toState:NO];
}

- (void)nudgeSelectedWithUserModel:(id)userModel
{
    [self.delegate nudgeSelectedWithUserModel:userModel];
}

#pragma mark - Private

- (NSIndexPath*)_centerCellIndexPath
{
    return [NSIndexPath indexPathForItem:kGridCenterCellIndex inSection:0];
}

@end
