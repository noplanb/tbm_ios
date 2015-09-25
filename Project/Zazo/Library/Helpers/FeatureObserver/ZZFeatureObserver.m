//
//  ZZFeatureObserver.m
//  Zazo
//
//  Created by ANODA on 9/17/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureObserver.h"
#import "ZZUserDataProvider.h"


static NSString* const kUnlockFeatureDefaultKey = @"kLastUnlockedFeatureKey";

typedef NS_ENUM(NSInteger, ZZFeatureTypeUninvited)
{
    ZZFeatureTypeUninvitedBothCamera = 2,
    ZZFeatureTypeUninvitedRecordAbortWithDragging = 4,
    ZZFeatureTypeUninvitedDeleteFriend = 4,
    ZZFeatureTypeUninvitedEarpiece = 5,
    ZZFeatureTypeUninvitedSpinWeel = 6
};

typedef NS_ENUM(NSInteger, ZZFeatureTypeInvited)
{
    ZZFeatureTypeInvitedBothCamera = 1,
    ZZFeatureTypeInvitedRecordAbortWithDragging = 3,
    ZZFeatureTypeInvitedDeleteFriend = 3,
    ZZFeatureTypeInvitedEarpiece = 4,
    ZZFeatureTypeInvitedSpinWeel = 5
};

@interface ZZFeatureObserver ()

@property (nonatomic, strong) NSNumber* unlockedFeatureType;
@property (nonatomic, assign) BOOL isInvitedUser;

@end

@implementation ZZFeatureObserver

+ (instancetype)sharedInstance
{
    static ZZFeatureObserver* sharedObserver;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[ZZFeatureObserver alloc] init];
    });
    return sharedObserver;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[[NSUserDefaults standardUserDefaults] rac_signalForSelector:@selector(setObject:forKey:)]
         subscribeNext:^(RACTuple* x) {
            NSString* featureName = x.second;
            if ([featureName isEqualToString:kUnlockFeatureDefaultKey])
            {
                self.unlockedFeatureType = x.first;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFeatureObserverFeatureUpdatedNotification
                                                                    object:nil];
            }
        }];
        [self _setupCurrenUnlockedFeatureType];
        [self _configrueIsInvitedUser];
    }
    return self;
}

- (void)_configrueIsInvitedUser
{
    ZZUserDomainModel* userModel = [ZZUserDataProvider authenticatedUser];
    self.isInvitedUser = userModel.isInvitee;
}

- (void)_setupCurrenUnlockedFeatureType
{
    self.unlockedFeatureType = [[NSUserDefaults standardUserDefaults] objectForKey:kUnlockFeatureDefaultKey];
}

- (BOOL)isBothCameraEnabled
{
    BOOL isEnabled;

    if (self.isInvitedUser)
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeInvitedBothCamera);
    }
    else
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeUninvitedBothCamera);
    }
    
    return isEnabled;
}

- (BOOL)isRecordAbortWithDraggedEnabled
{
    BOOL isEnabled;
    
    if (self.isInvitedUser)
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeInvitedRecordAbortWithDragging);
    }
    else
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeUninvitedRecordAbortWithDragging);
    }
    
    return isEnabled;
}

- (BOOL)isDeleteFriendsEnabled
{
    BOOL isEnabled;
    
    if (self.isInvitedUser)
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeInvitedDeleteFriend);
    }
    else
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeUninvitedDeleteFriend);
    }
    
    return isEnabled;
}

- (BOOL)isEarpieceEnabled
{
    BOOL isEnabled;
    
    if (self.isInvitedUser)
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeInvitedEarpiece);
    }
    else
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeUninvitedEarpiece);
    }
    
    return isEnabled;
}

- (BOOL)isSpinWeelEnabled
{
    BOOL isEnabled;
    
    if (self.isInvitedUser)
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeInvitedSpinWeel);
    }
    else
    {
        isEnabled = ([self.unlockedFeatureType integerValue] >= ZZFeatureTypeUninvitedSpinWeel);
    }
    
    return isEnabled;
}

@end
