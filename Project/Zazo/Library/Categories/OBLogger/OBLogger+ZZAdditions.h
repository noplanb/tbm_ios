//
//  OBLogger+ZZAdditions.h
//  Zazo
//
//  Created by Rinat on 25.01.16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <OBLogger/OBLogger.h>

@interface OBLogger (ZZAdditions)

- (void)dropOldLines:(NSUInteger)numberOfLines;

@end
