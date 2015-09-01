//
//  ZZFriendDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"
#import "FEMObjectMapping.h"

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
    NSString* username = self.firstName ? self.firstName : @"";
    if (username.length)
    {
        username = [username stringByAppendingString:@" "];
    }
    return [username stringByAppendingString:self.lastName ? self.lastName : @""];
}

- (BOOL)isCreator
{
    return [self.mKey isEqualToString:self.connectionCreatorMkey];
}

#pragma mark - Getters / Setters

- (ZZContactStatusType)contactStatusValue
{
    return ZZContactStatusTypeValueFromSrting(self.connectionStatus);
}

- (void)setContactStatusValue:(ZZContactStatusType)contactStatusValue
{
    self.connectionStatus = ZZContactStatusTypeStringFromValue(contactStatusValue);
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
        
        if (friendModel.firstName)
        {
            isFirstNameEqual = [friendModel.firstName isEqualToString:self.firstName];
        }
        else
        {
            isFirstNameEqual = (friendModel.firstName == self.firstName);
        }
            
        if (friendModel.lastName)
        {
            isLastNameEqual = [friendModel.lastName isEqualToString:self.lastName];
        }
        else
        {
            isLastNameEqual = (friendModel.lastName == self.lastName);
        }
        
        if (friendModel.mobileNumber)
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


@end
