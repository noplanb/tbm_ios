//
//  TBMUser.m
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMUser.h"
#import "TBMAppDelegate.h"
#import "TBMHttpManager.h"
#import "OBLogger.h"
#import "NBPhoneNumberUtil.h"
#import "MagicalRecord.h"

@implementation TBMUser

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}

+ (instancetype)getUser
{
    NSArray* users = [self MR_findAll];
    return [self MR_findFirstInContext:[self _context]]; //TODO: ??????/ // //!!! /  11111 ARGHH!
}

+ (void)destroy
{
    [self MR_truncateAllInContext:[self _context]];
    [[self _context] MR_saveToPersistentStoreAndWait];
}

+ (TBMUser *)createNewUser
{
    [TBMUser destroy];
    return [self MR_createEntityInContext:[self _context]];
}

+ (instancetype)createWithServerParams:(NSDictionary *)params
{
    NSManagedObjectContext* context = [self _context];
    [self MR_truncateAllInContext:context];
    [context MR_saveToPersistentStoreAndWait];
    
    TBMUser *user = [self MR_createEntityInContext:context];
    
    user.firstName = [params objectForKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    user.lastName = [params objectForKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    user.idTbm = [params objectForKey:SERVER_PARAMS_USER_ID_KEY];
    user.mkey = [params objectForKey:SERVER_PARAMS_USER_MKEY_KEY];
    user.auth = [params objectForKey:SERVER_PARAMS_USER_AUTH_KEY];
    user.mobileNumber = [params objectForKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];
    return user;
}

- (void)setupRegistredFlagTo:(BOOL)registred {
    TBMUser *user = [TBMUser getUser];
    if (!user) {
        return;
    }
    user.isRegistered = @YES;
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];
}

+ (void)saveRegistrationData:(NSDictionary *)params
{
    NSManagedObjectContext* context = [self _context];
    [self MR_truncateAllInContext:context];
    [context MR_saveToPersistentStoreAndWait];
    
    TBMUser *user = [self MR_createEntityInContext:context];
    
    if (!user) {
        return;
    }
    user.firstName = [params objectForKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    user.lastName = [params objectForKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    user.mobileNumber = [params objectForKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)setupIsInviteeFlagTo:(BOOL)flag
{
    self.isInvitee = @(flag);
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
}

//------------------------
// Phone number and region
//------------------------
+ (NSString *)phoneRegion
{
    NBPhoneNumberUtil *pu = [NBPhoneNumberUtil sharedInstance];
    
    TBMUser *u = [TBMUser getUser];
    
    if (u == nil)
        return @"US";
    
    NSError *err = nil;
    NBPhoneNumber *pn = [pu parse:u.mobileNumber defaultRegion:@"US" error:&err];
    
    if (err != nil)
        return @"US";
    
    return [pu getRegionCodeForNumber:pn];
}

@end
