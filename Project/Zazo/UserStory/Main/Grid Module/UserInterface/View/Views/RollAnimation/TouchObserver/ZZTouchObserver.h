//
//  ZZTouchObserver.h
//  Zazo
//
//  Created by ANODA on 27/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZGridPresenter.h"
#import "ZZGridView.h"
#import "ZZGridVC.h"
#import "ZZGridDataSource.h"
#import "ANMemoryStorage.h"
#import "Grid.h"

@interface ZZTouchObserver : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)observeTouch:(UITouch *)touch withEvent:(id)event;
- (instancetype)initWithGridView:(ZZGridView*)gridView;
- (void)hideMovedGridIfNeeded;

@end
