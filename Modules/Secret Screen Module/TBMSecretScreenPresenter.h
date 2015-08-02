//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMTutorialModuleInterface;

@interface TBMSecretScreenPresenter : NSObject
/**
 * Setup
 */
- (void)assignTutorialModule:(id <TBMTutorialModuleInterface>)tutorialModule;;

/**
* Presentation
*/
- (void)presentSecretScreenFromController:(UIViewController *)presentedController;

/**
* Event handling
*/
- (void)backButtonDidPress;

- (void)dispatchButtonDidPress;

- (void)debugSwitchDidChangeTo:(BOOL)on;

- (void)crashButtonDidPress;

- (void)logButtonDidPress;

- (void)stateButtonDidPress;

- (void)resetHintsButtonDidPress;

- (void)serverSegmentedControlDidChangeTo:(NSInteger)index;

- (void)setCustomServerURL:(NSString *)url;

- (void)dispatchTypeSegmentedControlDidChangeTo:(NSInteger)index;

@end