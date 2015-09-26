//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <pop/POPAnimation.h>
#import "ZZGridView.h"
#import "ZZRotationGestureRecognizer.h"

@class ZZRotator;
@class ZZGridHelper;
@class ZZRotationGestureRecognizer;
@class POPAnimatableProperty;

@protocol GridDelegate <NSObject>

- (void)rotationStoped;

@end


@interface ZZMovingGridView : UIView <POPAnimationDelegate, ZZGridViewDelegate>

@property (nonatomic, weak) id <GridDelegate> delegate;

@property (strong, nonatomic) ZZRotator *rotator;
@property (strong, nonatomic) ZZGridHelper *grid;

/**
* Angle, with current offset from initial position
*/
@property (assign, nonatomic) CGFloat cellsOffset;

/**
* Maximum offset value
*/
@property (assign, nonatomic) CGFloat maxCellsOffset;

/**
* cells to place (count of cells must be 9)
*/
@property (strong, nonatomic) NSArray *cells;

/**
* Set cells to be shown on view
*/

@property (strong, nonatomic) ZZRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, assign) BOOL isGridMoved;

- (void)setCells:(NSArray*)cells;
- (void)removeAllCells;

@end