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

@protocol ZZTouchObserverDelegate <NSObject>

- (void)stopPlaying;
- (void)spinRecognizerWasInstalled:(UIGestureRecognizer*)recognizer;

@end

@interface ZZGridRotationTouchObserver : NSObject

@property (nonatomic, weak) id <ZZTouchObserverDelegate> delegate;

- (instancetype)initWithGridView:(ZZGridView*)gridView;

@end
