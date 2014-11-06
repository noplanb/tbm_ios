//
//  TBMUser.m
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMUser.h"
#import "TBMAppDelegate.h"
#import "TBMHttpClient.h"
#import "OBLogger.h"


@implementation TBMUser

@dynamic firstName;
@dynamic lastName;
@dynamic idTbm;
@dynamic auth;
@dynamic mkey;
@dynamic mobileNumber;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext{
    return [[TBMUser appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription{
    return [NSEntityDescription entityForName:@"TBMUser" inManagedObjectContext:[TBMUser managedObjectContext]];
}

//-------
// Getter
//-------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMUser entityDescription]];
    return request;
}

+ (instancetype)getUser{
    __block NSError *error;
    __block NSArray *users;
    [[TBMUser managedObjectContext] performBlockAndWait:^{
        users = [[TBMUser managedObjectContext] executeFetchRequest:[TBMUser fetchRequest] error:&error];
    }];
    return [users firstObject];
}


//-------------------
// Create and destroy
//-------------------
+ (void)destroy{
    __block TBMUser *u = [TBMUser getUser];
    if (u){
        [[TBMUser managedObjectContext] performBlockAndWait:^{
            [[TBMUser managedObjectContext] deleteObject:u];
        }];
    }
}

+ (instancetype)createWithIdTbm:(NSString *)idTbm{
    [TBMUser destroy];
    __block TBMUser *user;
    [[TBMUser managedObjectContext] performBlockAndWait:^{
        user = (TBMUser *)[[NSManagedObject alloc] initWithEntity:[TBMUser entityDescription] insertIntoManagedObjectContext:[TBMUser managedObjectContext]];
        user.idTbm = idTbm;

    }];
    return user;
}

+ (instancetype)createWithServerParams:(NSDictionary *)params{
    [TBMUser destroy];
    __block TBMUser *user;
    [[TBMUser managedObjectContext] performBlockAndWait:^{
        user = (TBMUser *)[[NSManagedObject alloc] initWithEntity:[TBMUser entityDescription]
                                   insertIntoManagedObjectContext:[TBMUser managedObjectContext]];
        user.firstName  = [params objectForKey:SERVER_PARAMS_USER_FIRST_NAME_KEY];
        user.lastName   = [params objectForKey:SERVER_PARAMS_USER_LAST_NAME_KEY];
        user.idTbm      = [params objectForKey: SERVER_PARAMS_USER_ID_KEY];
        user.mkey       = [params objectForKey:SERVER_PARAMS_USER_MKEY_KEY];
        user.auth       = [params objectForKey:SERVER_PARAMS_USER_AUTH_KEY];
        user.mobileNumber = [params objectForKey:SERVER_PARAMS_USER_MOBILE_NUMBER_KEY];
    }];
    OB_INFO(@"Created user: %@", user);
    return user;
}

@end
