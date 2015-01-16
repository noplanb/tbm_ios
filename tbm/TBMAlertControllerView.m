//
//  TBMAlertControllerView.m
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertControllerView.h"

@implementation TBMAlertControllerView

@dynamic visualEffectView;
@dynamic actionsCollectionView;

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message {
    self = [super initWithTitle:title message:message];
    
    if (self) {
        // Init with nil effect because we don't want a blur effect on these alerts
        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
        [self.visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Action buttons background
        self.actionsCollectionView.backgroundColor = [UIColor colorWithRed:0.87f green:0.85f blue:0.81f alpha:1.0f];
    }
    
    return self;
}

@end
