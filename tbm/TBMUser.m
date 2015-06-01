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

@implementation TBMUser

@dynamic isRegistered;
@dynamic firstName;
@dynamic lastName;
@dynamic idTbm;
@dynamic auth;
@dynamic mkey;
@dynamic mobileNumber;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [[TBMUser appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription {
    return [NSEntityDescription entityForName:@"TBMUser" inManagedObjectContext:[TBMUser managedObjectContext]];
}

//-------
// Getter
//-------
+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMUser entityDescription]];
    return request;
}

+ (instancetype)getUser {
    NSError *error;
    NSArray *users;
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    NSFetchRequest *request = [TBMUser fetchRequest];

    users = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"TBMUser # getUser error: %@", error);
        return nil;
    }
    else {
        return [users firstObject];
    }
}


//-------------------
// Create and destroy
//-------------------
+ (void)destroy {
    __block TBMUser *u = [TBMUser getUser];
    if (u) {
        [[TBMUser managedObjectContext] performBlockAndWait:^{
            [[TBMUser managedObjectContext] deleteObject:u];
        }];
    }
}

<<<<<<< HEAD
+ (TBMUser *)createNewUser {
    [TBMUser destroy];
    //Insert user in context
    TBMUser *user = nil;
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    NSEntityDescription *description = [TBMUser entityDescription];

    user = (TBMUser *) [[NSManagedObject alloc] initWithEntity:description
                                insertIntoManagedObjectContext:context];
=======
+ (instancetype)createWithIdTbm:(NSString *)idTbm {
    [TBMUser destroy];
    __block TBMUser *user;
    [[TBMUser managedObjectContext] performBlockAndWait:^{
        user = (TBMUser *) [[NSManagedObject alloc] initWithEntity:[TBMUser entityDescription] insertIntoManagedObjectContext:[TBMUser managedObjectContext]];
        user.idTbm = idTbm;
        user.isRegistered = NO;
    }];
>>>>>>> 9100442b3f28deab76be9c97d5544fe30e6a26cc
    return user;
}

+ (instancetype)createWithServerParams:(NSDictionary *)params {
<<<<<<< HEAD

    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    TBMUser *user = [TBMUser createNewUser];
=======
    [TBMUser destroy];
    //Insert user in context
    TBMUser *user;
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    NSEntityDescription *description = [TBMUser entityDescription];

    user = (TBMUser *) [[NSManagedObject alloc] initWithEntity:description
                                insertIntoManagedObjectContext:context];
>>>>>>> 9100442b3f28deab76be9c97d5544fe30e6a26cc

    user.firstName = [params objectForKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    user.lastName = [params objectForKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    user.idTbm = [params objectForKey:SERVER_PARAMS_USER_ID_KEY];
    user.mkey = [params objectForKey:SERVER_PARAMS_USER_MKEY_KEY];
    user.auth = [params objectForKey:SERVER_PARAMS_USER_AUTH_KEY];
    user.mobileNumber = [params objectForKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
<<<<<<< HEAD
    [self saveCurrentContext];
    return user;
=======
    if (user.auth && user.mkey) {
        user.isRegistered = YES;
    }
    // Save data to store
    NSError *error;
    [context save:&error];
    if (error) {
        OB_ERROR(@"TBMUser # createWithServerParams - Failed to save - error: %@", error);
        return nil;
    } else {
        OB_INFO(@"Created user: %@", user);
        return user;
    }
>>>>>>> 9100442b3f28deab76be9c97d5544fe30e6a26cc
}

- (void)setupRegistredFlagTo:(BOOL)registred {
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    TBMUser *user = [TBMUser getUser];
    user.isRegistered = YES;
    [TBMUser saveCurrentContext];
}

+ (void)saveRegistrationData:(NSDictionary *)params {
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    TBMUser *user = [TBMUser createNewUser];
    user.firstName = [params objectForKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
    user.lastName = [params objectForKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
    user.mobileNumber = [params objectForKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    [self saveCurrentContext];
}

+ (void)saveCurrentContext {
    NSManagedObjectContext *context = [TBMUser managedObjectContext];
    // Save data to store
    NSError *error;
    [context save:&error];
    if (error) {
        OB_ERROR(@"TBMUser # saveCurrentContext - Failed to save - error: %@", error);
        return;
    } else {
        OB_INFO(@"TBMUser # saveCurrentContext - OK.");
        return;
    }
}

//------------------------
// Phone number and region
//------------------------
+ (NSString *)phoneRegion {
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
