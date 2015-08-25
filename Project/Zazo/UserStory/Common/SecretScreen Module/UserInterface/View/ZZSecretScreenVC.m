//
//  ZZSecretScreenVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenVC.h"
#import "ZZSecretScreenView.h"
#import "ZZPushedSecretScreenTypes.h"
#import "NSObject+ANUserDefaults.h"
#import "ANStoredSettingsManager.h"

static NSString *kTBMConfigServerStateKey = @"kTBMConfigServerStateKey";

@interface ZZSecretScreenVC ()

@property (nonatomic, strong) ZZSecretScreenView* secretView;

@end

@implementation ZZSecretScreenVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.secretView = [ZZSecretScreenView new];
        [self configureControlActions];
        [self configureNavigationBar];
        
    }
    return self;
}

- (void)loadView
{
    self.view = self.secretView;
}

- (void)configureNavigationBar
{
    self.title = NSLocalizedString(@"secret-controller.header.title", nil);
    UIBarButtonItem* doneButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"secret-controller.header.done.button.title", nil)
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(dismissController)];
    
    self.navigationItem.leftBarButtonItem = doneButton;
}

- (void)dismissController
{
    [self.eventHandler dismissSecretController];
}

#pragma mark - Control Actoins

- (void)configureControlActions
{
    [[self.secretView.serverTypeControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISegmentedControl* segmentControl) {
        
        [[ANStoredSettingsManager shared] saveCurrentServerIndex:segmentControl.selectedSegmentIndex];
        self.secretView.labelsInfoView.addressTextField.enabled = (segmentControl.selectedSegmentIndex == 2);
    }];
    
    [[self.secretView.debugModeSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *debugSwitch) {
        
    }];
    
    [[self.secretView.buttonView.crashButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventHandler presentPushedViewControllerWithType:ZZCrashType];
    }];
    
    [[self.secretView.buttonView.logsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventHandler presentPushedViewControllerWithType:ZZLogsType];
    }];
    
    [[self.secretView.buttonView.resetHintsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventHandler presentPushedViewControllerWithType:ZZResetHintsType];
    }];
    
    [[self.secretView.buttonView.stateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventHandler presentPushedViewControllerWithType:ZZStateType];
    }];
    
    [[self.secretView.buttonView.dispatchButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventHandler presentPushedViewControllerWithType:ZZDispatchType];
    }];
}

@end
