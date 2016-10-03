//
//  ZZMigrationManager.m
//  Zazo
//
//  Created by ANODA on 11/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


#import "ZZMigrationManager.h"
#import "MHWMigrationManager.h"

static NSString *const kSourceBaseName = @"tbm";
static NSString *const kDestinationBaseName = @"tbm-v2";

@implementation ZZMigrationManager

#pragma mark - Check is migration needed


- (BOOL)isMigrationNecessary
{
    BOOL isMigrationNeeded = YES;

    NSError *error = nil;
    NSURL *storeUrl = [self destinationUrl];

    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:&error];
    
    NSManagedObjectModel *destinationModel = [self coordinator].managedObjectModel;
    if (ANIsEmpty(sourceMetadata) ||
            [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
    {
        isMigrationNeeded = NO;
    }

    return isMigrationNeeded;
}


#pragma mark - Migration Part

- (BOOL)migrate
{
    MHWMigrationManager *migrationManager = [MHWMigrationManager new];
//    migrationManager.delegate = self;
    
    NSError *error = nil;
    
    BOOL OK = [migrationManager progressivelyMigrateURL:[self destinationUrl]
                                                 ofType:NSSQLiteStoreType
                                                toModel:[self managedObjectModel]
                                                  error:&error];
    if (OK)
    {
        NSLog(@"migration complete");
    }
    else
    {
        NSLog(@"migration error: %@", error.localizedDescription);
    }
    
    return OK;
}



#pragma mark - Lazy load

- (NSPersistentStoreCoordinator *)coordinator
{
    NSError *error;
    if (!_coordinator)
    {
        
        NSPersistentStoreCoordinator *coordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSString *sourcePathComponent = [NSString stringWithFormat:@"%@.sqlite", kDestinationBaseName];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sourcePathComponent];

        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:storeURL
                                         options:options
                                           error:&error])
        {
            ZZLogError(@"addPersistentStoreWithType: %@", error);
        }
        else
        {
            _coordinator = coordinator;
        }
    }


    return _coordinator;
}

- (NSManagedObjectContext *)mangedObjectContext
{
    if (!_mangedObjectContext)
    {
        _mangedObjectContext = [[NSManagedObjectContext alloc] init];
        [_mangedObjectContext setPersistentStoreCoordinator:[self coordinator]];
    }

    return _mangedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kSourceBaseName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }

    return _managedObjectModel;
}

- (NSURL *)destinationUrl
{
    NSString *destinationPathComponent = [NSString stringWithFormat:@"%@.sqlite", kDestinationBaseName];
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:destinationPathComponent];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
