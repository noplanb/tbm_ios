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


static NSInteger const kGridCellCount = 9;
static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSArray* gridModels;
@property (nonatomic, strong) NSMutableArray* friends;
@property (nonatomic, strong) id selectedUserModel;
@property (nonatomic, strong) ZZGridDomainModel* selectedModel;

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

///**
// *  Fuck....
// */
//
//- (void)createGridElements
//{
//    NSManagedObjectContext* context = [NSManagedObjectContext MR_context];
//    [TBMGridElement destroyAllOncontext:context];
//    
//    NSArray *friends = [TBMFriend MR_findAllInContext:context];
//    
//    for (NSInteger i = 0; i < 8; i++)
//    {
//        TBMGridElement *ge = [TBMGridElement createInContext:context];
//        ge.index = @(i);
//        if (i < friends.count)
//        {
//            TBMFriend *aFriend = friends[i];
//            ge.friend = aFriend;
//        }
//    }
//    [context MR_saveToPersistentStoreAndWait];
//}

- (void)loadData
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    
    NSMutableArray* gridModels = [NSMutableArray array];
    for (NSInteger count = 0; count < kGridCellCount; count++)
    {
        ZZGridDomainModel* model;
        if (count == kGridCenterCellIndex)
        {
            model = [ZZGridDomainModel new];
        }
        else
        {
            model = [ZZGridDomainModel new];
            model.index = @(count);
            if (friends.count > count)
            {
                ZZFriendDomainModel *aFriend = friends[count];
                model.relatedUser = aFriend;
            }
        }
        [gridModels addObject:model];
    }
    self.gridModels = [gridModels copy];
    [self.output dataLoadedWithArray:self.gridModels];
}

- (void)friendSelectedFromMenu:(ZZFriendDomainModel*)friend
{
    ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
    model.relatedUser = friend;
    [ZZGridDataProvider upsertModel:model];
}



- (NSInteger)centerCellIndex
{
    return self.gridModels.count / 2;
}

- (void)selectedPlusCellWithModel:(id)model
{
    self.selectedModel = model;
}

- (void)selectedUserWithModel:(id)model
{
    self.selectedUserModel = model;
    [self _updateSelectedModelWithUser];
}

- (void)loadFeedbackModel
{
    ANMessageDomainModel *model = [ANMessageDomainModel new];
    model.title = emailSubject;
    model.recipients = @[emailAddress];
    model.isHTMLMessage = YES;
    model.message = [NSString stringWithFormat:@"<font color = \"000000\"></br></br></br>---------------------------------</br>iOS: %@</br>Model: %@</br>User mKey: %@</br>App Version: %@</br>Build Version: %@ </font>", [[UIDevice currentDevice] systemVersion], [DeviceUtil hardwareDescription], [TBMUser getUser].mkey, [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleVersionKey]];
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

@end
