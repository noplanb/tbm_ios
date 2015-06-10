//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridDelegate <NSObject>
- (void)gridDidAppear:(TBMGridViewController *)gridViewController;
@end