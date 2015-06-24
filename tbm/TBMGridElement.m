//
//  TBMGridElement.m
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridElement.h"
#import "TBMAppDelegate.h"
#import "NSString+NSStringExtensions.h"

@implementation TBMGridElement

@dynamic friend;
@dynamic index;

//--------------------------------------
// Conveniene methods for managed object
//--------------------------------------
+ (TBMAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [[TBMGridElement appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription {
    return [NSEntityDescription entityForName:@"TBMGridElement" inManagedObjectContext:[TBMGridElement managedObjectContext]];
}


//-------------------
// Create and destroy
//-------------------
+ (instancetype)create {
    __block TBMGridElement *ge;
    [[TBMGridElement managedObjectContext] performBlockAndWait:^{
        ge = (TBMGridElement *) [[NSManagedObject alloc] initWithEntity:[TBMGridElement entityDescription] insertIntoManagedObjectContext:[TBMGridElement managedObjectContext]];
    }];
    return ge;
}

+ (void)destroyAll {
    [[TBMGridElement managedObjectContext] performBlockAndWait:^{
        for (TBMGridElement *ge in [TBMGridElement all]) {
            [[TBMGridElement managedObjectContext] deleteObject:ge];
        }
    }];
}

//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMGridElement entityDescription]];
    return request;
}

+ (NSArray *)all {
    __block NSError *error;
    __block NSArray *result;
    [[TBMGridElement managedObjectContext] performBlockAndWait:^{
        result = [[TBMGridElement managedObjectContext] executeFetchRequest:[TBMGridElement fetchRequest] error:&error];
    }];
    return result;
}

+ (NSArray *)allSorted {
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    return [[TBMGridElement all] sortedArrayUsingDescriptors:@[d]];
}


+ (instancetype)findWithIntIndex:(NSInteger)i {
    for (TBMGridElement *ge in [TBMGridElement all]) {
        if (i == [ge.index integerValue])
            return ge;
    }
    return nil;
}

+ (instancetype)findWithFriend:(TBMFriend *)friend {
    for (TBMGridElement *ge in [TBMGridElement all]) {
        if ([friend isEqual:ge.friend])
            return ge;
    }
    return nil;
}

+ (BOOL)friendIsOnGrid:(TBMFriend *)friend {
    return [TBMGridElement findWithFriend:friend] != nil;
}

+ (instancetype)firstEmptyGridElement {
    for (TBMGridElement *ge in [TBMGridElement allSorted]) {
        if (ge.friend == nil)
            return ge;
    }
    return nil;
}


//--------------------
// Setters and getters
//--------------------
- (void)setIntIndex:(NSInteger)index {
    self.index = [NSNumber numberWithInteger:index];
}

+ (BOOL)hasSentVideos:(NSUInteger)index {
    TBMFriend *friend = [TBMGridElement findWithIntIndex:index].friend;
    return [friend hasOutgoingVideo];
}

- (NSInteger)getIntIndex {
    return [self.index integerValue];
}

@end
