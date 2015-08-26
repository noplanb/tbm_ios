//
//  ZZSecretScreenVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenVC.h"
#import "ZZSecretScreenView.h"
#import "ZZSettingsModel.h"

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
    }
    return self;
}

- (void)loadView
{
    self.view = self.secretView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureControlActions];
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    //TODO: to ANBarButton item
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
    [self.eventHandler dismissController];
}


#pragma mark - View Interface

- (void)updateWithModel:(ZZSettingsModel*)model
{
    //TODO: better naming
    self.secretView.serverTypeControl.selectedSegmentIndex = model.serverIndex;
    self.secretView.debugModeSwitch.on = model.isDebugEnabled;
    
    ZZSecretLabelsInfoView* view = self.secretView.labelsInfoView;
    view.versionLabel.text = model.version;
    view.firstNameLabel.text = model.firstName;
    view.lastNameLabel.text = model.lastName;
    view.phoneNumberLabel.text = model.phoneNumber;
    
    if (!ANIsEmpty(model.serverURLString))
    {
        view.addressTextField.text = model.serverURLString;
    }
}

- (void)updateCustomServerFieldToEnabled:(BOOL)isEnabled
{
    ANDispatchBlockToMainQueue(^{
        self.secretView.labelsInfoView.addressTextField.enabled = isEnabled;
    });
}


#pragma mark - Control Actoins

- (void)configureControlActions
{
    RACSignal* segmentSignal = [self.secretView.serverTypeControl rac_signalForControlEvents:UIControlEventValueChanged];
    [segmentSignal subscribeNext:^(UISegmentedControl* segmentControl) {
        [self.eventHandler updateServerStateTo:segmentControl.selectedSegmentIndex];
    }];
    
    RACSignal* debugSwitchSignal = [self.secretView.debugModeSwitch rac_signalForControlEvents:UIControlEventValueChanged];
    [debugSwitchSignal subscribeNext:^(UISwitch *debugSwitch) {
        [self.eventHandler updateDebugModeStateTo:debugSwitch.isOn];
    }];
    
    self.secretView.buttonView.crashButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler forceCrash];
    }];
    
    self.secretView.buttonView.logsButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler presentLogsController];
    }];
    
    self.secretView.buttonView.resetHintsButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler resetHints];
    }];
    
    self.secretView.buttonView.stateButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler presentStateController];
    }];
    
    self.secretView.buttonView.dispatchButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler dispatchData];
    }];
}

@end
