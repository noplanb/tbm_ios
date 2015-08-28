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
#import "NSObject+ANSafeValues.h"

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

- (void)setupWithAllVideos:(NSArray*)allVideos incomeDandling:(NSArray*)income outcomeDandling:(NSArray*)outcome
{
    [self.storage updateStorageWithBlock:^{
       
        
        
        [allVideos enumerateObjectsUsingBlock:^(ZZDebugStateDomainModel* obj, NSUInteger idx, BOOL *stop) {
            
            
            
            NSString* sectionTitle = [NSString stringWithFormat:@"Income: %@ - %@", [NSObject an_safeString:obj.userID], [NSObject an_safeString:obj.username]];
            
            [self.storage setSectionHeaderModel:sectionTitle
                                forSectionIndex:[self.storage.sections count]];
            
//            [self.storage addobje]
            
        }];
        
        
        
        
//        //incoming
//        [self.storage addItems:[self _convertedToViewModels:model.incomingVideoItems]
//                     toSection:ZZDebugStateSectionsIncomingVideos];
//        
//        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-videos.title", nil)
//                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
//        
//        //outgoing
//        [self.storage addItems:[self _convertedToViewModels:model.outgoingVideoItems]
//                     toSection:ZZDebugStateSectionsIncomingVideos];
//        
//        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.outgoing-videos.title", nil)
//                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
        
//        //incoming-dandling
//        [self.storage addItems:[self _convertedToViewModels:model.incomingDanglingVideoItems]
//                     toSection:ZZDebugStateSectionsIncomingVideos];
//        
//        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
//                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
//        
//        //outgoing-dandling
//        [self.storage addItems:[self _convertedToViewModels:model.outgoingDanglingVideoItems]
//                     toSection:ZZDebugStateSectionsIncomingVideos];
//        
//        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
//                            forSectionIndex:ZZDebugStateSectionsIncomingVideos];
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
