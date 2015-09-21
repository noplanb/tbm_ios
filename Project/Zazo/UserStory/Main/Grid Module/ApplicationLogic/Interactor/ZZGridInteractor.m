 //
//  ZZGridInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZMenuCellViewModel.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCellViewModel.h"
#import "ANMessageDomainModel.h"
#import "DeviceUtil.h"
#import "TBMUser.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZPhoneHelper.h"
#import "ZZUserDataProvider.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendsTransportService.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "TBMFriend.h"
#import "ZZCommonNetworkTransportService.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSArray* gridModels;
//@property (nonatomic, strong) NSMutableArray* friends;
@property (nonatomic, strong) id selectedUserModel;
@property (nonatomic, strong) ZZGridDomainModel* selectedModel;
@property (nonatomic, assign) BOOL selectedFromGrid;
@property (nonatomic, strong) NSString* selectedPhoneNumber;
@property (nonatomic, strong) ZZFriendDomainModel* currentFriend;
@property (nonatomic, strong) ZZFriendDomainModel* containedModel;

@end

@implementation ZZGridInteractor

- (void)loadData
{
//    [self.friends addObjectsFromArray:[ZZFriendDataProvider loadAllFriends]];
    NSArray *friendArrayForSorting = [ZZFriendDataProvider loadAllFriends];
    [friendArrayForSorting sortedArrayUsingComparator:^NSComparisonResult(ZZFriendDomainModel* obj1, ZZFriendDomainModel* obj2) {
        return [obj1.lastActionTimestamp compare:obj2.lastActionTimestamp];
    }];
    
    NSArray* gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    
    NSMutableArray* gridModels = [NSMutableArray array];
    for (NSInteger count = 0; count < kGridFriendsCellCount; count++)
    {
        ZZGridDomainModel* model;
        if (gridStoredModels.count > count)
        {
            model = gridStoredModels[count];
        }
        else
        {
            model = [ZZGridDomainModel new];
        }
        model.index = @(count);
        if (friendArrayForSorting.count > count)
        {
            ZZFriendDomainModel *aFriend = friendArrayForSorting[count];
            model.relatedUser = aFriend;
        }
        [gridModels addObject:model];

        model = [ZZGridDataProvider upsertModel:model];
    }
    self.gridModels = [NSArray arrayWithArray:gridModels];
    [self.output dataLoadedWithArray:self.gridModels];
    
    //#pragma mark - Old // TODO:
    [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {}];
}

- (void)friendSelectedFromMenu:(ZZFriendDomainModel*)friend
{
    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friend];
    if (!shouldBeVisible)
    {
        friend.contactStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friend];
        [ZZFriendDataProvider upsertFriendWithModel:friend];
        
        [[ZZFriendsTransportService changeModelContactStatusForUser:friend.mKey
                                                          toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
        }];
    }
    
    if (self.selectedFromGrid)
    {
        self.selectedModel.relatedUser = friend;
        [ZZGridDataProvider upsertModel:self.selectedModel];
        [self.output modelUpdatedWithUserWithModel:self.selectedModel];
    }
    else
    {
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        
        if (ANIsEmpty(model))
        {
            model = [self _getGridModelWithLatestAction];
            model.relatedUser = friend;
        }
        else
        {
            model.relatedUser = friend;
        }
        
        [ZZGridDataProvider upsertModel:model];
        
        [self.output updateGridWithModel:model];
    }
    self.selectedFromGrid = NO;
}

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model
{
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* gridModel, NSUInteger idx, BOOL *stop) {
        if ([gridModel.relatedUser.idTbm isEqualToString:model.idTbm]) {
            gridModel.relatedUser = nil;
            [ZZGridDataProvider upsertModel:gridModel];
            [self.output updateGridWithModel:gridModel];
            *stop = YES;
        }
    }];
}

- (void)selectedPlusCellWithModel:(id)model
{
    self.selectedModel = model;
    self.selectedFromGrid = YES;
}

- (void)selectedUserWithModel:(id)model
{
    self.selectedUserModel = model;
    
    if ([model isKindOfClass:[ZZFriendDomainModel class]])
    {
        if (self.selectedFromGrid)
        {
            [self _updateSelectedModelWithUser]; //TODO: selected zazo friend logic
        }
        else
        {
            ZZFriendDomainModel* containedUser;
            if (![self _isFriendsOnGridContainFriendModel:self.selectedUserModel withContainedFriend:&containedUser])
            {
                [self friendSelectedFromMenu:self.selectedUserModel];
            }
            else
            {
                [self.output gridContainedFriend:containedUser];
            }
        }
    }
    else //invite friend from contact logic
    {
        if ([self _isFriendsOnGridContainContactFriendModel:model])
        {
            //implement check friend logic
            [self.output gridContainedFriend:self.containedModel];
        }
        else
        {
            NSArray* validNumbers = [ZZPhoneHelper validatePhonesFromContactModel:model];
            if (!ANIsEmpty(validNumbers))
            {
                if (validNumbers.count > 1)
                {
                    [self.output userHaSeveralValidNumbers:validNumbers];
                }
                else
                {
                    //send has app and invitation requests
                    [self checkIfAnInvitedUserHasApp:[validNumbers firstObject]];
                }
            }
            else
            {
                [self.output userHasNoValidNumbers:model];
            }
        }
    }
}

- (void)userSelectedPhoneNumber:(NSString*)phoneNumber
{
    [self checkIfAnInvitedUserHasApp:phoneNumber];
}

- (void)inviteUserThatHasNoAppInstalled
{
    [self getInvitedFriendFromServer];
}

- (void)addNewFriendToGridModelsArray
{
    [self friendSelectedFromMenu:self.currentFriend];
}

- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel
{
    friendModel.lastActionTimestamp = [NSDate date];
    [ZZFriendDataProvider upsertFriendWithModel:friendModel];
}

- (void)handleNotificationForFriend:(TBMFriend *)friendEntity
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friendEntity];
    
    __block ZZGridDomainModel *modelThatContainCurrentFriend;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.relatedUser.mKey isEqualToString:friendModel.mKey])
        {
            modelThatContainCurrentFriend = obj;
            *stop = YES;
        }
    }];
    
    if (ANIsEmpty(modelThatContainCurrentFriend))
    {
            ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        
            if (ANIsEmpty(model))
            {
                model = [self _getGridModelWithLatestAction];
                model.relatedUser = friendModel;
            }
            else
            {
                model.relatedUser = friendModel;
            }
            [ZZGridDataProvider upsertModel:model];
            [self.output updateGridWithModelFromNotification:modelThatContainCurrentFriend];
    }
    else
    {
        modelThatContainCurrentFriend.relatedUser = friendModel;
        [ZZGridDataProvider upsertModel:modelThatContainCurrentFriend];
        [self.output updateGridWithModelFromNotification:modelThatContainCurrentFriend];
    }
}

- (void)loadFeedbackModel
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    
    ANMessageDomainModel *model = [ANMessageDomainModel new];
    model.title = emailSubject;
    model.recipients = @[emailAddress];
    model.isHTMLMessage = YES;
    model.message = [NSString stringWithFormat:@"<font color = \"000000\"></br></br></br>---------------------------------</br>iOS: %@</br>Model: %@</br>User mKey: %@</br>App Version: %@</br>Build Version: %@ </font>", [[UIDevice currentDevice] systemVersion], [DeviceUtil hardwareDescription], user.mkey, [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleVersionKey]];
    [self.output feedbackModelLoadedSuccessfully:model];
}

- (void)_updateSelectedModelWithUser
{
    ZZFriendDomainModel* friendModel = [self friendModelFromMenuModel:self.selectedUserModel];
    ZZFriendDomainModel* containedUser;
    if (![self _isFriendsOnGridContainFriendModel:friendModel withContainedFriend:&containedUser])
    {
        self.selectedModel.relatedUser = friendModel;
        [ZZGridDataProvider upsertModel:self.selectedModel];
        [self.output modelUpdatedWithUserWithModel:self.selectedModel];
    }
    else
    {
        [self.output gridContainedFriend:containedUser];
    }
    self.selectedFromGrid = NO;
}

- (ZZFriendDomainModel*)friendModelFromMenuModel:(id)model
{
    ZZFriendDomainModel* friendModel;
    
    if ([model isMemberOfClass:[ZZContactDomainModel class]])
    {
        ZZContactDomainModel* contactModel = (ZZContactDomainModel*)model;
        friendModel = [ZZFriendDomainModel new];
        friendModel.firstName = contactModel.firstName;
        friendModel.lastName = contactModel.lastName;
        friendModel.mobileNumber = [[contactModel.phones allObjects] firstObject];
    }
    else
    {
        friendModel = (ZZFriendDomainModel*)model;
    }
    
    return friendModel;
}

- (BOOL)_isFriendsOnGridContainFriendModel:(ZZFriendDomainModel *)friendModel withContainedFriend:(ZZFriendDomainModel**)containtedUser
{
    __block BOOL isContainModel = NO;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.relatedUser isEqual:friendModel])
        {
            *containtedUser = obj.relatedUser;
            isContainModel = YES;
            *stop = YES;
        }
    }];
    
    return isContainModel;
}

- (BOOL)_isFriendsOnGridContainContactFriendModel:(ZZContactDomainModel *)contactModel
{
    __block BOOL isContainModel = NO;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.relatedUser fullName] isEqualToString:[contactModel fullName]])
        {
            isContainModel = YES;
            *stop = YES;
            self.containedModel = obj.relatedUser;
        }
    }];
    
    if (!isContainModel)
    {
        NSArray* validNumbers = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];
        if (!ANIsEmpty(validNumbers))
        {
            [validNumbers enumerateObjectsUsingBlock:^(NSString* number, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *trimmedNumber = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
                [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
                    if ([[obj.relatedUser mobileNumber] isEqualToString:trimmedNumber])
                    {
                        isContainModel = YES;
                        self.containedModel = obj.relatedUser;
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    
    return isContainModel;
}

#pragma mark - API

- (void)checkIfAnInvitedUserHasApp:(NSString *)phoneNumber
{
    self.selectedPhoneNumber = phoneNumber;
    
    [[ZZFriendsTransportService checkIsUserHasProfileWithPhoneNumber:phoneNumber] subscribeNext:^(NSDictionary* responseObject) {
        if ([[responseObject objectForKey:@"has_app"] isEqualToString:@"false"]) //TODO: need model for response object?
        {
            //user has no app
            NSString *firstName = [(ZZContactDomainModel*)self.selectedUserModel firstName];
            [self.output userHasNoAppInstalled:firstName];
        }
        else
        {
            //user has app installed
            [self getInvitedFriendFromServer];
        }
    } error:^(NSError *error) {
        //TODO: handle error
    }];
}

- (void)getInvitedFriendFromServer
{
    NSString *firstName = [(ZZContactDomainModel*)self.selectedUserModel firstName];
    NSString *lastName = [(ZZContactDomainModel*)self.selectedUserModel lastName];
    
    [[ZZFriendsTransportService inviteUserWithPhoneNumber:self.selectedPhoneNumber firstName:[NSObject an_safeString:firstName] andLastName:[NSObject an_safeString:lastName]] subscribeNext:^(NSDictionary* objectArray) {
        
        ZZFriendDomainModel* friend = [FEMObjectDeserializer deserializeObjectExternalRepresentation:objectArray usingMapping:[ZZFriendDomainModel mapping]];
        self.currentFriend = friend;
        
        [self.output friendRecievedFromeServer:friend];
        
    } error:^(NSError *error) {
        //TODO: handle Error
    }];
}

#pragma mark - Privat

- (ZZGridDomainModel*)_getGridModelWithLatestAction
{
    NSArray *sortingByLastAction = [NSArray arrayWithArray:self.gridModels];
    
    [sortingByLastAction sortedArrayUsingComparator:^NSComparisonResult(ZZGridDomainModel* obj1, ZZGridDomainModel* obj2) {
        return [obj1.relatedUser.lastActionTimestamp compare:obj2.relatedUser.lastActionTimestamp];
    }];
    
    return sortingByLastAction[0];
}

- (NSUInteger)lastAddedFriendIndex
{
    //TODO: (EventsFlow) return last added friend
    return 0;
}

- (NSString*)lastAddedFriendName
{
    //TODO: (EventsFlow) return last added friend's name
    return @"Vasya";
}

- (NSInteger)countOfFriendsAtGrid
{
    __block NSInteger counter = 0;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if (!ANIsEmpty(obj.relatedUser))
        {
            counter++;
        }
    }];
    
    return counter;
}

@end
