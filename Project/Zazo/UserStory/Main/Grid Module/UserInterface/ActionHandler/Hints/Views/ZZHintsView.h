//
//  ZZHintsView.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
@class ZZHintsViewModel;

@protocol ZZHintsViewDelegate <NSObject>

- (void)hintViewHiddenWithType:(ZZHintsType)type;

@end


@interface ZZHintsView : UIView

@property (nonatomic, weak) id <ZZHintsViewDelegate> delegate;

- (void)updateWithHintsViewModel:(ZZHintsViewModel*)viewModel;
- (void)updateWithHintsViewModel:(ZZHintsViewModel*)viewModel andIndex:(NSInteger)index;
- (ZZHintsViewModel*)hintModel;

@end
