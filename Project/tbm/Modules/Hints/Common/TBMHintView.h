/**
 *
 * Tutorial screen base class
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TBMEventsFlowModulePresenter.h"
#import "TBMHintArrow.h"
#import "TBMEventsFlowDataSource.h"
#import "TBMGridModuleInterface.h"


NSString *const kTBMTutorialFontName;

@interface TBMHintView : UIView

@property(nonatomic, strong) UIColor *fillColor;
/**
 * Array of UIBezierPath paths for cut out
 */
@property(nonatomic, strong) NSArray *framesToCutOut;

/**
 * Array of TBMHintArrow
 */
@property(nonatomic, strong) NSArray *arrows;

@property(nonatomic) BOOL showGotItButton;

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

@property(nonatomic) BOOL dismissAfterAction;

/**
 * Shows hint
 */
- (void)showHintInGrid:(id <TBMGridModuleInterface>)gridModule;

/**
 * Dismiss hint
 */
- (void)dismiss;


@end