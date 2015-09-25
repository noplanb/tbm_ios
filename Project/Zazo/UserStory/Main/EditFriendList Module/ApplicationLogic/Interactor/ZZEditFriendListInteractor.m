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
#import "ZZUserDataProvider.h"

@interface ZZEditFriendListInteractor ()

@property (nonatomic, strong) ZZFriendDomainModel* selectedFriendModel;

@end

@implementation ZZEditFriendListInteractor

- (void)loadData
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *array) {
        
        NSArray *friendsArray = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                                      usingMapping:[ZZFriendDomainModel mapping]];
        
        [friendsArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendObject, NSUInteger idx, BOOL * _Nonnull stop) {
            
            friendObject.isConnectionCreator = ![[ZZUserDataProvider authenticatedUser].mkey isEqualToString:friendObject.connectionCreatorMkey];
        }];
        
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
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByTarget;
                visible = NO;
            } break;
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByBoth;
                visible = NO;
            } break;
                
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeEstablished;
                visible = YES;
            } break;
                
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByCreator;
                visible = YES;
            } break;

            default: break;
        }
    }
    else
    {
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByCreator;
                visible = NO;
            } break;
                
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByBoth;
                visible = NO;
            } break;
                
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeEstablished;
                visible = YES;
            } break;
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                self.selectedFriendModel.connectionStatusValue = ZZConnectionStatusTypeHiddenByTarget;
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
