//
//  ZZMigrationManager.h
//  Zazo
//
//  Created by ANODA on 11/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


@interface ZZMigrationManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *mangedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

- (BOOL)isMigrationNecessary;

- (BOOL)migrate;

- (NSURL *)destinationUrl;

- (NSURL *)sourceUrl;

@end
