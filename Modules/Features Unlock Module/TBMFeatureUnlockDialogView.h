/**
 *
 * Feature unlock dialog base class
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TBMEventsFlowModulePresenter.h"
#import "TBMEventsFlowDataSource.h"
#import "TBMGridModuleInterface.h"
#import "TBMDialogViewInterface.h"

@class TBMFeatureUnlockModulePresenter;

NSString *const kTBMFeatureUnlockDialogHeaderFontName;
NSString *const kTBMFeatureUnlockDialogSubHeaderFontName;
NSString *const kTBMFeatureUnlockDialogFeatureFontName;
NSString *const kTBMFeatureUnlockDialogButtonFontName;

@interface TBMFeatureUnlockDialogView : UIView <TBMDialogViewInterface>

@property(nonatomic, weak) TBMFeatureUnlockModulePresenter *presenter;

/**
 * Configuration
 */
@property(nonatomic, strong) NSString *featureDescription;

@end