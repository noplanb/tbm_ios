//
//  ZZDebugStateDataSource.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZDebugStateItemDomainModel.h"
#import "ZZDebugStateDomainModel.h"

@implementation ZZDebugStateDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage new];
    }
    return self;
}

- (void)setupWithModel:(ZZDebugStateDomainModel*)model
{
    [self.storage updateStorageWithBlock:^{
       
        //incoming
        [self.storage addItems:[self _convertedToViewModels:model.incomingVideoItems]
                     toSection:ZZDebugStateSectionsIncomingVideos];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-videos.title", nil)
                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
        
        //outgoing
        [self.storage addItems:[self _convertedToViewModels:model.outgoingVideoItems]
                     toSection:ZZDebugStateSectionsIncomingVideos];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.outgoing-videos.title", nil)
                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
        
        //incoming-dandling
        [self.storage addItems:[self _convertedToViewModels:model.incomingDanglingVideoItems]
                     toSection:ZZDebugStateSectionsIncomingVideos];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
        
        //outgoing-dandling
        [self.storage addItems:[self _convertedToViewModels:model.outgoingDanglingVideoItems]
                     toSection:ZZDebugStateSectionsIncomingVideos];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
    }];
}


#pragma mark - Private

- (NSArray*)_convertedToViewModels:(NSArray*)models
{
    return [[models.rac_sequence map:^id(id value) { // TODO: group by user ID
        return [ZZDebugStateCellViewModel viewModelWithItem:value];
    }] array];
}

@end
