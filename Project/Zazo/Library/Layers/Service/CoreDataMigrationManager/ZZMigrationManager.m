//
//  ZZMigrationManager.m
//  Zazo
//
//  Created by ANODA on 11/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


#import "ZZMigrationManager.h"

static NSString *const kSourceBaseName = @"tbm";
static NSString *const kDestinationBaseName = @"tbm-v2";

@implementation ZZMigrationManager

#pragma mark - Check is migration needed


- (BOOL)isMigrationNecessary
{
    BOOL isMigrationNeeded = YES;

    NSError *error = nil;
    NSURL *storeUrl = [self sourceUrl];

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

//    NSURL *sourceUrl = [self sourceUrl];
//    NSError *error = nil;
//    NSManagedObjectModel *destinationModel = self.coordinator.managedObjectModel;
//
//    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
//                                                                                              URL:sourceUrl
//                                                                                            error:&error];
//
//    if (!sourceMetadata)
//    {
//        ZZLogError(@"metadataForPersistentStoreOfType: %@", error);
//        return NO;
//    }
//
//    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
//
//    NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel
//                                                                     destinationModel:destinationModel
//                                                                                error:&error];
//
//    if (!mappingModel)
//    {
//        ZZLogError(@"inferredMappingModelForSourceModel: %@", error);
//        return NO;
//    }
//
//    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
//    
//    
//    NSDictionary *options = nil;// @{NSMigratePersistentStoresAutomaticallyOption: @YES,
//                              //NSInferMappingModelAutomaticallyOption: @YES};
//    
//    if (![migrationManager migrateStoreFromURL:sourceUrl
//                                                 type:NSSQLiteStoreType
//                                              options:options
//                                     withMappingModel:mappingModel
//                                     toDestinationURL:nil
//                                      destinationType:NSSQLiteStoreType
//                                   destinationOptions:options
//                                                error:&error])
//    {
//        ZZLogError(@"migrateStoreFromURL: %@", error);
//        return NO;
//    }
//
    return  YES;
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

- (NSURL *)sourceUrl
{
    return [NSURL fileURLWithPath:[[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kDestinationBaseName]]];
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
