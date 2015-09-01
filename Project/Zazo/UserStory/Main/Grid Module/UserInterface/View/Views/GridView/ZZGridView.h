//
//  ZZGridView.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "RotationGestureRecognizer.h"
#import "ZZGridViewHeader.h"

@protocol ZZGridViewDelegate <NSObject, UIGestureRecognizerDelegate>

- (void)handleRotationGesture:(RotationGestureRecognizer *)recognizer;

@end

@protocol ZZGridViewEventDelegate <NSObject>

- (void)menuSelected;
- (void)editFriendsSelected;

@end

@interface ZZGridView : UIView

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) ZZGridViewHeader* headerView;
@property (nonatomic, strong) RotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, weak) id <ZZGridViewEventDelegate> eventDelegate;

- (void)updateWithDelegate:(id <ZZGridViewDelegate>)delegate;


@end
