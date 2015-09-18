//
//  ZZFeatureObserver.m
//  Zazo
//
//  Created by ANODA on 9/17/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureObserver.h"


static NSString* const kUnlockFeatureDefaultKey = @"kLastUnlockedFeatureKey";

typedef NS_ENUM(NSInteger, ZZFeatureType)
{
    ZZFeatureTypeBothCamera,
    ZZFeatureTypeRecordAbortWithDragging,
    ZZFeatureTypeDeleteFriend,
    ZZFeatureTypeEarpiece,
    ZZFeatureTypeSpinWeel
};


@interface ZZFeatureObserver ()

@property (nonatomic, strong) NSNumber* unlockedFeatureType;

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
            }
        }];
        [self _setupCurrenUnlockedFeatureType];
    }
    return self;
}

- (void)_setupCurrenUnlockedFeatureType
{
    self.unlockedFeatureType = [[NSUserDefaults standardUserDefaults] objectForKey:kUnlockFeatureDefaultKey];
}

- (BOOL)isBothCameraEnabled
{
    return NO;
}

- (BOOL)isRecordAbortWithDraggedEnabled
{
    return NO;
}

- (BOOL)isDeleteFriendsEnabled
{
    return NO;
}

- (BOOL)isEarpieceEnabled
{
    return NO;
}

- (BOOL)isSpinWeelEnabled
{
    return NO;
}

@end
