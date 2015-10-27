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

@protocol ZZGridRotationTouchObserverDelegate <NSObject>

- (void)stopPlaying;

@end

@interface ZZGridRotationTouchObserver : NSObject

@property (nonatomic, weak) id <ZZGridRotationTouchObserverDelegate> delegate;
@property (nonatomic, assign) BOOL isMoving;

- (instancetype)initWithGridView:(ZZGridView*)gridView;
- (BOOL)isGridRotate;

@end
