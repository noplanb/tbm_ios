//
//  ZZGridView.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRotationGestureRecognizer.h"
#import "ZZGridContainerView.h"

@protocol ZZGridViewDelegate <NSObject>

- (void)updatedFrame:(CGRect)frame;

- (void)placeCells;

@end

@interface ZZGridView : UIView

@property (nonatomic, weak) id <ZZGridViewDelegate> delegate;
@property (nonatomic, assign) BOOL isRotationEnabled;
@property (nonatomic, strong) ZZGridContainerView *itemsContainerView;

//rotation
@property (nonatomic, assign) CGFloat calculatedCellsOffset;
@property (nonatomic, assign) CGFloat maxCellsOffset;

- (NSArray *)items;


@end
