//
//  ZZFriendDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import MagicalRecord;

#import "ZZFriendDomainModel.h"
#import "ZZVideoDomainModel.h"
#import "FEMObjectMapping.h"
#import "ZZUserPresentationHelper.h"
#import "ZZStoredSettingsManager.h"
#import "ZZFriendDataHelper.h"

const struct ZZFriendDomainModelAttributes ZZFriendDomainModelAttributes = {
        .idTbm = @"idTbm",
        .firstName = @"firstName",
        .lastName = @"lastName",
        .mobileNumber = @"mobileNumber",
        .mKey = @"mKey",
        .cKey = @"cKey",
        .uploadRetryCount = @"uploadRetryCount",
        .lastActionTimestamp = @"lastActionTimestamp",
        .lastVideoStatusEventType = @"lastVideoStatusEventType",
        .lastIncomingVideoStatus = @"lastIncomingVideoStatus",
        .outgoingVideoItemID = @"outgoingVideoItemID",
        .outgoingVideoStatus = @"outgoingVideoStatus",
        .hasApp = @"hasApp",
        .friendshipStatus = @"friendshipStatus",
        .isFriendshipCreator = @"isFriendshipCreator",
        .friendshipCreatorMkey = @"friendshipCreatorMkey",
        .cid = @"cid",
        .abilities = @"abilities",
        .abilitiesArray = @"abilitiesArray",
        .avatarTimestamp = @"avatarTimestamp",
        .useAsThumbnail = @"useAsThumbnail"
};

@implementation ZZFriendDomainModel

@dynamic abilitiesArray;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.lastActionTimestamp = [NSDate date];
    }
    return self;
}

- (UIImage *)thumbnail
{
    return nil;
}

+ (FEMObjectMapping *)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {

        [mapping addAttributesFromDictionary:
                @{ZZFriendDomainModelAttributes.firstName : @"first_name",
                    ZZFriendDomainModelAttributes.lastName : @"last_name",
                    ZZFriendDomainModelAttributes.mobileNumber : @"mobile_number",
                    ZZFriendDomainModelAttributes.idTbm : @"id",
                    ZZFriendDomainModelAttributes.mKey : @"mkey",
                    ZZFriendDomainModelAttributes.cKey : @"ckey",
                    ZZFriendDomainModelAttributes.friendshipStatus : @"connection_status",
                    ZZFriendDomainModelAttributes.friendshipCreatorMkey : @"connection_creator_mkey",
                    ZZFriendDomainModelAttributes.cid : @"cid",
                    ZZFriendDomainModelAttributes.abilitiesArray: @"abilities",
//                    ZZFriendDomainModelAttributes.avatarTimestamp: @"avatar.timestamp",
                    ZZFriendDomainModelAttributes.useAsThumbnail: @"avatar.use_as_thumbnail"
                }];

        FEMAttribute *hasAppAttribute = [FEMAttribute mappingOfProperty:ZZFriendDomainModelAttributes.hasApp
                                                        toKeyPath:@"has_app"
                                                              map:^id(NSString *value) {
                                                                  return @([value isEqualToString:@"true"]);
                                                              }];
        
        static NSNumberFormatter *formatter;
        
        if (formatter == nil)
        {
            formatter = [[NSNumberFormatter alloc] init];
        }
        
        FEMAttribute *avatarAttribute = [FEMAttribute mappingOfProperty:ZZFriendDomainModelAttributes.avatarTimestamp
                                                        toKeyPath:@"avatar.timestamp"
                                                              map:^id(NSString *value) {
                                                                  
                                                                  if ([value isKindOfClass:[NSNull class]])
                                                                  {
                                                                      return nil;
                                                                  }
                                                                  
                                                                  if (value == nil)
                                                                  {
                                                                      return nil;
                                                                  }
                                                                  
                                                                  return [formatter numberFromString:value];
                                                              }];
        
        
        [mapping addAttribute:avatarAttribute];
        [mapping addAttribute:hasAppAttribute];
    }];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"idTbm=%@", self.idTbm];
    [description appendFormat:@", firstName=%@", self.firstName];
    [description appendFormat:@", lastName=%@", self.lastName];
    [description appendFormat:@", mKey=%@", self.mKey];
    [description appendFormat:@", cKey=%@", self.cKey];
    [description appendFormat:@", mobileNumber=%@", self.mobileNumber];
    [description appendString:@">"];
    return description;
}


- (NSString *)fullName
{
    return [ZZUserPresentationHelper fullNameWithFirstName:self.firstName lastName:self.lastName];
}

- (BOOL)hasApp
{
    return self.isHasApp;
}

- (BOOL)isCreator
{
    return [self.friendshipCreatorMkey isEqualToString:self.mKey];
}

- (BOOL)hasIncomingVideo
{
    return [self.videos count] > 0;
}

- (BOOL)hasDownloadedVideo
{    
    if (ANIsEmpty(self.videos))
    {
        return NO;
    }

    for (ZZVideoDomainModel *videoModel in self.videos)
    {
        if (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
                videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed)
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)hasDownloadingVideo
{
    for (ZZVideoDomainModel *videoModel in self.videos)
    {
        if (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloading)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)setAbilitiesArray:(NSArray<NSString *> *)abilitiesArray
{
    self.abilities = ZZAbilitiesFromArray(abilitiesArray);
}

- (NSArray<NSString *> *)abilitiesArray
{
    return ZZArrayFromAbilities(self.abilities);
}

#pragma mark - Getters / Setters

- (ZZFriendshipStatusType)friendshipStatusValue
{
    return ZZFriendshipStatusTypeValueFromSrting(self.friendshipStatus);
}

- (void)setFriendshipStatusValue:(ZZFriendshipStatusType)friendshipStatusValue
{
    self.friendshipStatus = ZZFriendshipStatusTypeStringFromValue(friendshipStatusValue);
}

- (NSUInteger)hash
{
    return [self.firstName hash] ^ [self.lastName hash] ^ [self.mobileNumber hash];
}

- (BOOL)isEqual:(id)object
{
    BOOL isFirstNameEqual = NO;
    BOOL isLastNameEqual = NO;
    BOOL isPhoneEqual = NO;

    if ([object isKindOfClass:[self class]])
    {
        isFirstNameEqual = YES;
        isLastNameEqual = YES;
        isPhoneEqual = YES;

        ZZFriendDomainModel *friendModel = object;

        if ([friendModel.firstName isKindOfClass:[NSString class]])
        {
            isFirstNameEqual = [friendModel.firstName isEqualToString:self.firstName];
        }
        else
        {
            isFirstNameEqual = (friendModel.firstName == self.firstName);
        }

        if ([friendModel.lastName isKindOfClass:[NSString class]])
        {
            isLastNameEqual = [friendModel.lastName isEqualToString:self.lastName];
        }
        else
        {
            isLastNameEqual = (friendModel.lastName == self.lastName);
        }

        if ([friendModel.mobileNumber isKindOfClass:[NSString class]])
        {
            isPhoneEqual = [friendModel.mobileNumber isEqualToString:self.mobileNumber];
        }
        else
        {
            isPhoneEqual = (friendModel.mobileNumber == self.mobileNumber);
        }
    }

    return (isFirstNameEqual && isLastNameEqual && isPhoneEqual);
}

- (ZZMenuContactType)contactType
{
    return ZZFriendshipStatusTypeZazoFriend;
}

#pragma mark - Friend Name

- (NSString *)displayName
{
    NSInteger maxLength = 100;
    NSString *name;

    if ([ZZFriendDataHelper isUniqueFirstName:self.firstName friendID:self.idTbm])
    {
        name = self.firstName;
    }
    else
    {
        name = [NSString stringWithFormat:@"%@. %@", [self firstInitial], self.lastName];
    }

    // Limit to 12 characgters
    if (name.length > maxLength)
        name = [name substringWithRange:NSMakeRange(0, maxLength - 1)];

    return name;
}

- (NSString *)shortFirstName
{
    return [[self displayName] substringWithRange:NSMakeRange(0, MIN(6, [[self displayName] length]))];
}

- (NSString *)firstInitial
{
    return [self.firstName substringToIndex:1];
}

@end
