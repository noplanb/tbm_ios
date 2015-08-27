//
//  NSManagedObject+CDAdditions.m
//  ControlDo
//
//  Created by ANODA on 5/8/15.
//  Copyright (c) 2015 Oksana Kovalchuk. All rights reserved.
//

#import "NSManagedObject+ANAdditions.h"
#import "ZZBaseDomainModel.h"

@implementation NSManagedObject (ANAdditions)

+ (id)an_objectWithItemID:(NSString *)itemID context:(NSManagedObjectContext*)context
{
    return [self an_objectWithItemID:itemID context:context shouldCreate:YES];
}

+ (id)an_objectWithItemID:(NSString *)itemID context:(NSManagedObjectContext *)context shouldCreate:(BOOL)shouldCreate
{
    if (ANIsEmpty(itemID))
    {
        return nil;
    }
    NSManagedObject* object;
    
    NSString* entityName = NSStringFromClass([self class]);
    
    if (!ANIsEmpty(entityName))
    {
        NSFetchRequest* isObjectExists = [NSFetchRequest fetchRequestWithEntityName:entityName];
        isObjectExists.predicate = [NSPredicate predicateWithFormat:@"%K = %@", ZZBaseDomainModelAttributes.idTbm, itemID];
        NSError* error;
        NSArray* objects = [[context executeFetchRequest:isObjectExists error:&error] copy];

        if (objects.count)
        {
            object = [objects firstObject];
        }
        else if (shouldCreate)
        {
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        }
    }
    return object;
}

@end
