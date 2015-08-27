//
//  NSManagedObject+CDAdditions.h
//  ControlDo
//
//  Created by ANODA on 5/8/15.
//  Copyright (c) 2015 Oksana Kovalchuk. All rights reserved.
//

@interface NSManagedObject (ANAdditions)

+ (id)an_objectWithItemID:(NSString *)itemID context:(NSManagedObjectContext*)context;
+ (id)an_objectWithItemID:(NSString *)itemID context:(NSManagedObjectContext *)context shouldCreate:(BOOL)shouldCreate;

@end
