//
//  ZZGridView.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRotationGestureRecognizer.h"
#import "ZZGridViewHeader.h"
#import "ZZGridContainerView.h"

@protocol ZZGridViewDelegate <NSObject, UIGestureRecognizerDelegate>

- (void)handleRotationGesture:(ZZRotationGestureRecognizer *)recognizer;

@end

@interface ZZGridView : UIView

@property (nonatomic, strong) ZZGridViewHeader* headerView;
@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, assign) BOOL isRotationEnabled;
@property (nonatomic, strong) ZZGridContainerView* itemsContainerView;

- (NSArray*)items;

- (void)updateWithDelegate:(id<ZZGridViewDelegate>)delegate;
- (void)updateSwithCameraButtonWithState:(BOOL)isHidden;

@end
