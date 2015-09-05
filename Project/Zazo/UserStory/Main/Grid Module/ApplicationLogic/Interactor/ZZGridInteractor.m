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


static NSInteger const kGridCellCount = 9;
static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) id selectedUserModel;
@property (nonatomic, strong) ZZGridDomainModel* selectedModel;
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
    
    for (NSInteger count = 0; count<kGridCellCount; count++)
    {
        id model;
        if (count == kGridCenterCellIndex)
        {
            model = [ZZGridDomainModel new];
        }
        else
        {
            model = [ZZGridDomainModel new];
        }
        
        [self.dataArray addObject:model];
    }
    
    [self.output dataLoadedWithArray:self.dataArray];
}

- (NSInteger)centerCellIndex
{
    return self.dataArray.count / 2;
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
    [self.output loadedFeedbackDomainModel:model];
}

- (void)_updateSelectedModelWithUser
{
    ZZFriendDomainModel* friendModel = [self friendModelFromMenuModel:self.selectedUserModel];
    ZZFriendDomainModel* containedUser;
    if (![self _isFriendsOnGridContainFriendModel:friendModel withContainedFriend:&containedUser])
    {
        [self.friendArray addObject:friendModel];
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
