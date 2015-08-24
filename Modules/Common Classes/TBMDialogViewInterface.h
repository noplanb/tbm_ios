//
// Created by Maksim Bazarov on 22/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@protocol TBMGridModuleInterface;

@protocol TBMDialogViewInterface <NSObject>
/**
 * Shows event handler dialog in view
 */
- (void)showInGrid:(id <TBMGridModuleInterface>)gridModule;

/**
 * Dismiss the view
 */
- (void)dismiss;

@end