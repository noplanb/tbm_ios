//
//  ZZTouchObserver.h
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZGridView.h"
#import "ZZGridVC.h"
#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"

@interface ZZGridRotationTouchObserver : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign, readonly) BOOL isRotating;

- (instancetype)initWithGridView:(ZZGridView *)gridView;
- (void)placeCells;

@end
