//
//  TBMUser.m
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMUser.h"
#import "TBMAppDelegate.h"


@implementation TBMUser

@dynamic firstName;
@dynamic lastName;
@dynamic idTbm;

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
+ (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMUser entityDescription]];
    return request;
}

+ (id)get
{
    NSError *error;
    NSArray *users = [[TBMUser managedObjectContext] executeFetchRequest:[TBMUser fetchRequest] error:&error];
    return [users firstObject];
}


//-------------------
// Create and destroy
//-------------------
+ (void)destroy{
    [[TBMUser managedObjectContext] deleteObject:[TBMUser get]];
}

+ (id)createWithidTbm:(NSNumber *)idTbm{
    [TBMUser destroy];
    TBMUser *user = (TBMUser *)[[NSManagedObject alloc] initWithEntity:[TBMUser entityDescription] insertIntoManagedObjectContext:[TBMUser managedObjectContext]];
    user.idTbm = idTbm;
    [[TBMUser appDelegate] saveContext];
    return user;
}

@end
