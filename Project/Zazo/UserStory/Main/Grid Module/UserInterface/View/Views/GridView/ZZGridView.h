//
//  ZZGridView.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZRotationGestureRecognizer.h"
#import "ZZGridViewHeader.h"

@protocol ZZGridViewDelegate <NSObject, UIGestureRecognizerDelegate>

- (void)handleRotationGesture:(ZZRotationGestureRecognizer *)recognizer;

@end

@interface ZZGridView : UIView

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) ZZGridViewHeader* headerView;
@property (nonatomic, strong) ZZRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, assign) BOOL isRotationEnabled;

- (void)updateWithDelegate:(id <ZZGridViewDelegate>)delegate;

@end
