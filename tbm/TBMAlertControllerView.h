//
//  TBMAlertControllerView.h
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCAlertControllerView.h"

@interface TBMAlertControllerView : SDCAlertControllerView

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UICollectionView *actionsCollectionView;

@end
