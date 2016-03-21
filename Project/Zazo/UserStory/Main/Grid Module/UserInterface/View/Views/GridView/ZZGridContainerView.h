//
//  ZZGridContainerView.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridRotationTouchObserver;

@interface ZZGridContainerView : UIView

@property (nonatomic, strong) NSArray <UIView *>* items;

@property (nonatomic, strong) ZZGridRotationTouchObserver* touchObserver;

- (instancetype)initWithSegmentsCount:(NSInteger)segmentsCount;
- (void)showDimScreenForItemWithIndex:(NSUInteger)index;
- (void)hideDimScreen;

@end
