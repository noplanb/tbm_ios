//
//  Friend.m
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriend.h"
#import "TBMAppDelegate.h"

@implementation TBMFriend

@dynamic firstName;
@dynamic lastName;
@dynamic outgoingVideoStatus;
@dynamic incomingVideoStatus;
@dynamic viewIndex;
@dynamic idTbm;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext
{
    return [[TBMFriend appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:@"TBMFriend" inManagedObjectContext:[TBMFriend managedObjectContext]];
}

//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMFriend entityDescription]];
    return request;
}

+ (NSArray *)all
{
    NSError *error;
    return [[TBMFriend managedObjectContext] executeFetchRequest:[TBMFriend fetchRequest] error:&error];
}

+ (id)findWithId:(NSNumber *)idTbm
{
    return [self findWithAttributeString:@"idTbm" numberValue:idTbm];
}

+ (id)findWithViewIndex:(NSNumber *)viewIndex
{
    return [self findWithAttributeString:@"viewIndex" numberValue:viewIndex];
}

+ (id)findWithAttributeString:(NSString *)attribute numberValue:(NSNumber *)value{
    NSFetchRequest *request = [TBMFriend fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *friends = [[TBMFriend managedObjectContext] executeFetchRequest:request error:&error];
    return [friends lastObject];
}

//-------------------
// Create and destroy
//-------------------
+ (id)newWithId:(NSNumber *)idTbm
{
    TBMFriend *friend = (TBMFriend *)[[NSManagedObject alloc] initWithEntity:[TBMFriend entityDescription] insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
    friend.idTbm = idTbm;
    [[TBMFriend appDelegate] saveContext];
    return friend;
}

+ (NSUInteger)destroyAll
{
    NSArray *allFriends = [TBMFriend all];
    NSUInteger count = [allFriends count];
    for (TBMFriend *friend in allFriends) {
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
    return count;
}

+ (void)destroyWithId:(NSNumber *)idTbm
{
    TBMFriend *friend = [TBMFriend findWithId:idTbm];
    if ( friend != nil ){
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
}

@end
