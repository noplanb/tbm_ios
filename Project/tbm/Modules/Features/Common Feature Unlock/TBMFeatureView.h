/**
 *
 * Tutorial screen base class
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TBMEventsFlowModulePresenter.h"
#import "TBMEventsFlowDataSource.h"
#import "TBMGridModuleInterface.h"

@class TBMFeaturePresenter;

NSString *const kTBMFeatureUnlockDialogHeaderFontName;
NSString *const kTBMFeatureUnlockDialogSubHeaderFontName;
NSString *const kTBMFeatureUnlockDialogFeatureFontName;
NSString *const kTBMFeatureUnlockDialogButtonFontName;

@interface TBMFeatureView : UIView

@property(nonatomic) BOOL showShowMeButton;
@property(nonatomic, strong) NSString *featureDescription;

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

@property(nonatomic, strong) UIView *dialogView;

@property(nonatomic, weak) TBMFeaturePresenter *presenter;

/**
 * Shows hint
 */
- (void)showHintInGrid:(id <TBMGridModuleInterface>)gridModule;

/**
 * Dismiss hint
 */
- (void)dismiss;

@end