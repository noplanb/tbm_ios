//
//  ZZSecretScreenStrategy.h
//  Zazo
//
//  Created by ANODA on 21/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZSecretScreenStrategy <NSObject>

- (NSArray*)intersectionFrames;

- (void)intersectRectWithIndex:(NSInteger)index;
- (void)fillArray;
- (BOOL)isLockedSuccess;
- (void)resetValidatoinArray;

@end
