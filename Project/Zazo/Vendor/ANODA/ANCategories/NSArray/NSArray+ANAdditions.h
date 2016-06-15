//
//  NSArray+ANAdditions.h
//
//  Created by Oksana Kovalchuk on 26/6/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface NSArray<ObjectType> (ANAdditions)

- (void)an_enumerateObjectsDrainingEveryIterations:(NSUInteger)iterationsBetweenDrains
                                        usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block;

- (NSArray *)an_arrayByTransformingObjectsWithBlock:(id(^)(id))block;

- (id)an_objectAtIndex:(NSUInteger)index;

- (NSArray <ObjectType> *)zz_arrayWithoutObject:(ObjectType)obj;

@end
