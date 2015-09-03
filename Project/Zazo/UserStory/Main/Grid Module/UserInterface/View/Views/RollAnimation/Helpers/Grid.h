//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import <pop/POPAnimation.h>
#import "ZZGridView.h"
#import "RotationGestureRecognizer.h"

@class Rotator;
@class GridHelper;
@class RotationGestureRecognizer;
@class POPAnimatableProperty;

@protocol GridDelegate <NSObject>

- (void)rotationStoped;

@end


@interface Grid : UIView <POPAnimationDelegate, ZZGridViewDelegate>

@property (nonatomic, weak) id <GridDelegate> delegate;

@property (strong, nonatomic) Rotator *rotator;
@property (strong, nonatomic) GridHelper *grid;

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

@property (strong, nonatomic) RotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

- (void) setCells:(NSArray *)cells;
- (void)removeAllCells;

@end