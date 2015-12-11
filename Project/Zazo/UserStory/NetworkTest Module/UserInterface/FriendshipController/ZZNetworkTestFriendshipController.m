//
//  ZZNetworkTestFriendshipController.m
//  Zazo
//
//  Created by ANODA on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNetworkTestFriendshipController.h"
#import "TBMUser.h"
#import "ZZUserDataProvider.h"
#import "TBMFriend.h"
#import "ZZFriendDataProvider.h"
#import "ZZContactDomainModel.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZGridTransportService.h"
#import "ZZFriendDataUpdater.h"

@implementation ZZNetworkTestFriendshipController

+ (void)updateFriendShipIfNeededWithCompletion:(void(^)(NSString* actualFriendID))completion
{
    ZZUserDomainModel* authUser = [ZZUserDataProvider authenticatedUser];
    if (!ANIsEmpty(authUser))
    {
        TBMFriend* activeTestFriend = [ZZFriendDataProvider friendWithMobileNumber:authUser.mobileNumber];
        if (activeTestFriend)
        {
            if (completion)
            {
                completion(activeTestFriend.idTbm);
            }
            
            [self _executeCompeltionWithId:activeTestFriend.idTbm completion:completion];
            
        }
        else
        {
            [self _createFriendshipWithUser:authUser completion:completion];
        }
    }
}


#pragma mark - Private

+ (void)_createFriendshipWithUser:(ZZUserDomainModel*)userModel completion:(void(^)(NSString* actualFriendID))completion
{
    ZZContactDomainModel* friendContactModel = [ZZContactDomainModel modelWithFirstName:userModel.firstName lastName:userModel.lastName];
    ZZCommunicationDomainModel* communicationModel = [ZZCommunicationDomainModel new];
    communicationModel.contact = userModel.mobileNumber;
    friendContactModel.primaryPhone = communicationModel;
    
    [self _loadFriendModelFromContact:friendContactModel userModel:userModel completion:completion];
    
}

+ (void)_loadFriendModelFromContact:(ZZContactDomainModel*)contact userModel:(ZZUserDomainModel*)userModel completion:(void(^)(NSString* actualFriendID))completion
{
    [[ZZGridTransportService inviteUserToApp:contact] subscribeNext:^(ZZFriendDomainModel* x) {
        
        NSString* friendID = nil;

        [ZZFriendDataUpdater upsertFriend:x];
        TBMFriend* activeTestFriend = [ZZFriendDataProvider friendWithMobileNumber:userModel.mobileNumber];
        
        if (!ANIsEmpty(activeTestFriend))
        {
            friendID = activeTestFriend.idTbm;
        }
        
        [self _executeCompeltionWithId:friendID completion:completion];
        
    } error:^(NSError *error) {
        [self _executeCompeltionWithId:nil completion:completion];
    }];
}

+ (void)_executeCompeltionWithId:(NSString*)friendID completion:(void(^)(NSString* actualFriendID))completion
{
    if (completion)
    {
        completion(friendID);
    }
}

@end
