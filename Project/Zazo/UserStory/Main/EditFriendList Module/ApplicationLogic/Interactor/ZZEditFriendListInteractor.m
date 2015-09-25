//
//  ZZEditFriendListInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListInteractor.h"
#import "ZZFriendDomainModel.h"
#import "ZZAddressBookDataProvider.h"
#import "ZZFriendsTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendDataProvider.h"

@interface ZZEditFriendListInteractor ()

@property (nonatomic, strong) ZZFriendDomainModel* selectedFriendModel;

@end

@implementation ZZEditFriendListInteractor

- (void)loadData
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *array) {
        
        NSArray *friendsArray = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                                      usingMapping:[ZZFriendDomainModel mapping]];
        [self.output dataLoaded:[self sortArrayByFirstName:friendsArray]];

    } error:^(NSError* error) {
        
    }];
}

- (void)changeContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel
{
    self.selectedFriendModel = friendModel;
    BOOL visible = NO;
    
    if ([friendModel isCreator])
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByTarget;
                visible = NO;
            } break;
            case ZZContactStatusTypeHiddenByCreator:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByBoth;
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByTarget:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeEstablished;
                visible = YES;
            } break;
                
            case ZZContactStatusTypeHiddenByBoth:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByCreator;
                visible = YES;
            } break;

            default: break;
        }
    }
    else
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByCreator;
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByTarget:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByBoth;
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByCreator:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeEstablished;
                visible = YES;
            } break;
            case ZZContactStatusTypeHiddenByBoth:
            {
                self.selectedFriendModel.contactStatusValue = ZZContactStatusTypeHiddenByTarget;
                visible = YES;
            } break;
                
            default: break;
        }
    }
    
    
    
    [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey toVisible:visible] subscribeNext:^(NSDictionary* response) {
        
        [ZZFriendDataProvider upsertFriendWithModel:self.selectedFriendModel];
        [self.output contactSuccessfullyUpdated:friendModel toVisibleState:visible];
        
    } error:^(NSError *error) {
        
    }];
}

- (NSArray *)sortArrayByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: dangerous
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}


@end
