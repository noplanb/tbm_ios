//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMNextFeatureDialogPresenter;
@protocol TBMGridModuleInterface;


@interface TBMNextFeatureDialogView : UIView

@property(nonatomic, weak) TBMNextFeatureDialogPresenter *presenter;

- (void)showHintInGrid:(id <TBMGridModuleInterface>)gridModule;

- (void)dismiss;
@end