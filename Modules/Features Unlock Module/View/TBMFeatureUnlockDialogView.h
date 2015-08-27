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

@interface TBMFeatureUnlockDialogView : UIView <TBMDialogViewInterface>


/**
 * Configuration
 */
@property(nonatomic, strong) NSString *featureDescription;

@end