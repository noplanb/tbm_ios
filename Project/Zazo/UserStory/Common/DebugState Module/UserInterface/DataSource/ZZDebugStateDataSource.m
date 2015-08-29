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
            
            NSInteger section = [self.storage.sections count];
            
            NSString* sectionIncomeTitle = [self _sectionTitleWithStatusString:@"Incoming" model:obj];
            [self.storage setSectionHeaderModel:sectionIncomeTitle forSectionIndex:section];
            [self.storage addItems:obj.incomingVideoItems toSection:section];
            
            NSString* sectionOutgoingTitle = [self _sectionTitleWithStatusString:@"Outgoing" model:obj];
            [self.storage setSectionHeaderModel:sectionOutgoingTitle forSectionIndex:section + 1];
            [self.storage addItems:obj.outgoingVideoItems toSection:section + 1];
        }];
        
        //incoming-dandling
        NSInteger incomingSection = [self.storage.sections count];
        [self.storage addItems:income toSection:incomingSection];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
                            forSectionIndex:incomingSection];
        
        //outgoing-dandling
        NSInteger outcomingSection = [self.storage.sections count];
        [self.storage addItems:outcome toSection:outcomingSection];
        
        [self.storage setSectionHeaderModel:NSLocalizedString(@"debug-state.incoming-dandling-videos.title", nil)
                            forSectionIndex:outcomingSection];
    }];
}


#pragma mark - Private

- (NSString*)_sectionTitleWithStatusString:(NSString*)status model:(ZZDebugStateDomainModel*)model
{
    return [NSString stringWithFormat:@"%@: %@ - %@",
                                    status,
                                    [NSObject an_safeString:model.userID],
                                    [NSObject an_safeString:model.username]];
}

- (NSArray*)_convertedToViewModels:(NSArray*)models
{
    return [[models.rac_sequence map:^id(id value) {
        return [ZZDebugStateCellViewModel viewModelWithItem:value];
    }] array];
}

@end
