//
//  ZZHintsController.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
#import "ZZGridCellViewModel.h"

@class ZZHintsDomainModel;

@protocol ZZHintsControllerDelegate <NSObject>

- (void)hintWasDismissedWithType:(ZZHintsType)type;

- (UIView *)hintPresentedView;

- (void)showMenuTab;

- (void)showGridTab;

@end

@interface ZZHintsController : NSObject

@property (nonatomic, weak) id <ZZHintsControllerDelegate> delegate;

- (void)showHintWithType:(ZZHintsType)type
              focusFrame:(CGRect)focusFrame
               withIndex:(NSInteger)index
               withModel:(ZZFriendDomainModel *)friendModel
         formatParameter:(NSString *)parameter;

- (void)hideHintView;

@property (nonatomic, assign) CGPoint frameOffset;

@end
