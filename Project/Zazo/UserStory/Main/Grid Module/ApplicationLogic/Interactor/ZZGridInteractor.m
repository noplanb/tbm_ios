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
#import "ZZGridCollectionCellViewModel.h"
#import "ANMessageDomainModel.h"
#import "DeviceUtil.h"
#import "TBMUser.h"


static NSInteger const kGridCellCount = 9;
static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) id selectedUserModel;
@property (nonatomic, strong) ZZGridCollectionCellViewModel* selectedCellModel;
@property (nonatomic, strong) NSMutableArray* friendArray;

@end

@implementation ZZGridInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.friendArray = [NSMutableArray array];
    }
    return self;
}

- (void)loadData
{
    self.dataArray = [NSMutableArray array];
    
    for (NSInteger count = 0;count<kGridCellCount;count++)
    {
        id model;
        if (count == kGridCenterCellIndex)
        {
            model = [ZZGridCenterCellViewModel new];
        }
        else
        {
            model = [ZZGridCollectionCellViewModel new];
        }
        
        [self.dataArray addObject:model];
    }
    
    [self.output dataLoadedWithArray:self.dataArray];
}

- (NSInteger)centerCellIndex
{
    return self.dataArray.count/2;
}

- (void)selectedPlusCellWithModel:(ZZGridCollectionCellViewModel *)model
{
    self.selectedCellModel = model;
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
    [self.output loadedFeedbackDomainModel:model];
}

- (void)_updateSelectedModelWithUser
{
    
    ZZFriendDomainModel* friendModel = [self friendModelFromMenuModel:self.selectedUserModel];
    ZZFriendDomainModel* containdedUser;
    if (![self _isFriendsOnGridContainFriendModel:friendModel withContainedFriend:&containdedUser])
    {
        [self.friendArray addObject:friendModel];
        self.selectedCellModel.domainModel.relatedUser = friendModel;
        [self.output modelUpdatedWithUserWithModel:self.selectedCellModel];
    }
    else
    {
        [self.output gridContainedFriend:containdedUser];
    }
}

- (ZZFriendDomainModel*)friendModelFromMenuModel:(ZZMenuCellViewModel*)model
{
    ZZFriendDomainModel* friendModel;
    
    if ([model.item isMemberOfClass:[ZZContactDomainModel class]])
    {
        ZZContactDomainModel* contactModel = (ZZContactDomainModel*)model.item;
        friendModel = [ZZFriendDomainModel new];
        friendModel.firstName = contactModel.firstName;
        friendModel.lastName = contactModel.lastName;
        friendModel.mobileNumber = [[contactModel.phones allObjects] firstObject];
    }
    else
    {
        friendModel = (ZZFriendDomainModel*)model.item;
    }
    
    return friendModel;
}

- (BOOL)_isFriendsOnGridContainFriendModel:(ZZFriendDomainModel *)friendModel withContainedFriend:(ZZFriendDomainModel**)containtedUser
{
    __block BOOL isContainModel = NO;
    
    [self.friendArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel* obj, NSUInteger idx, BOOL *stop) {
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
