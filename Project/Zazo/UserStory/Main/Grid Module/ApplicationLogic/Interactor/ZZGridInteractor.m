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

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSArray* gridModels;
@property (nonatomic, strong) NSMutableArray* friends;
@property (nonatomic, strong) id selectedUserModel;
@property (nonatomic, strong) ZZGridDomainModel* selectedModel;
@property (nonatomic, strong) NSString* selectedPhoneNumber;
@property (nonatomic, strong) ZZFriendDomainModel* currentFriend;

@end

@implementation ZZGridInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.friends = [NSMutableArray array];
    }
    return self;
}

- (void)loadData
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    
    NSMutableArray* gridModels = [NSMutableArray array];
    for (NSInteger count = 0; count < kGridFriendsCellCount; count++)
    {
        ZZGridDomainModel* model;
        model = [ZZGridDomainModel new];
        model.index = @(count);
        if (friends.count > count)
        {
            ZZFriendDomainModel *aFriend = friends[count];
            model.relatedUser = aFriend;
        }
        [gridModels addObject:model];

        [ZZGridDataProvider upsertModel:model];
    }
    self.gridModels = [gridModels copy];
    [self.output dataLoadedWithArray:self.gridModels];
//    
//#pragma mark - Old // TODO:
//    
//    - (void)postRegistrationBoot
//    {
//        [TBMS3CredentialsManager refreshFromServer:nil];
//    }
}

- (void)friendSelectedFromMenu:(ZZFriendDomainModel*)friend isContact:(BOOL)contact
{
    //TODO: last loadFirstEmptyGridElement not work!
    
//    ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
//    model.relatedUser = friend;
//    [ZZGridDataProvider upsertModel:model];

    //TODO: clean datasource storage before new output?
    
//    if (contact)
//    {
//        [self.output updateGridWithModel:model];
//    }
}


- (void)selectedPlusCellWithModel:(id)model
{
    self.selectedModel = model;
}

- (void)selectedUserWithModel:(id)model
{
    self.selectedUserModel = model;
    
    if ([model isKindOfClass:[ZZFriendDomainModel class]])
    {
        [self _updateSelectedModelWithUser]; //TODO: selected zazo friend logic
    }
    else //invite friend from contact logic
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
    [self friendSelectedFromMenu:self.currentFriend isContact:YES];
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
        [self.friends addObject:friendModel];
        self.selectedModel.relatedUser = friendModel;
        [self.output modelUpdatedWithUserWithModel:self.selectedModel];
    }
    else
    {
        [self.output gridContainedFriend:containedUser];
    }
    
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
    
    [self.friends enumerateObjectsUsingBlock:^(ZZFriendDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:friendModel])
        {
            *containtedUser = obj;
            isContainModel = YES;
            *stop = YES;
        }
    }];
    
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

 @end
