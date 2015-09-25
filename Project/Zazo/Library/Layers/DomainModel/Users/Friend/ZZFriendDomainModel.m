//
//  ZZFriendDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"
#import "FEMObjectMapping.h"
#import "ZZUserPresentationHelper.h"

const struct ZZFriendDomainModelAttributes ZZFriendDomainModelAttributes = {
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
    .connectionStatus = @"connectionStatus",
    .connectionCreatorMkey = @"connectionCreatorMkey",
};

@implementation ZZFriendDomainModel
//        TODO:
//        friend.timeOfLastAction = [NSDate date];
//        friend.hasApp = servHasApp;

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        
        [mapping addAttributesFromDictionary:
         @{ZZFriendDomainModelAttributes.firstName          : @"first_name",
           ZZFriendDomainModelAttributes.lastName           : @"last_name",
           ZZFriendDomainModelAttributes.mobileNumber       : @"mobile_number",
           ZZBaseDomainModelAttributes.idTbm                : @"id",
           ZZFriendDomainModelAttributes.mKey               : @"mkey",
           ZZFriendDomainModelAttributes.cKey               : @"ckey",
           ZZFriendDomainModelAttributes.connectionStatus   : @"connection_status",
           ZZFriendDomainModelAttributes.connectionCreatorMkey : @"connection_creator_mkey"}];
        
        FEMAttribute* attribute = [FEMAttribute mappingOfProperty:ZZFriendDomainModelAttributes.hasApp
                                                        toKeyPath:@"has_app"
                                                              map:^id(NSString* value) {
            return @([value isEqualToString:@"true"]);
        }];
        [mapping addAttribute:attribute];
    }];
}

- (NSString*)photoURLString
{
    return nil; // TODO:
}

- (UIImage *)photoImage
{
    return nil; // TODO:
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
    return [self.mKey isEqualToString:self.connectionCreatorMkey];
}

- (BOOL)hasIncomingVideo
{
    return [self.videos count] > 0;
}

#pragma mark - Getters / Setters

- (ZZConnectionStatusType)connectionStatusValue
{
    return ZZConnectionStatusTypeValueFromSrting(self.connectionStatus);
}

- (void)setConnectionStatusValue:(ZZConnectionStatusType)contactStatusValue
{
    self.connectionStatus = ZZConnectionStatusTypeStringFromValue(contactStatusValue);
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
        
        ZZFriendDomainModel* friendModel = object;
        
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
    return ZZConnectionStatusTypeZazoFriend;
}

@end
