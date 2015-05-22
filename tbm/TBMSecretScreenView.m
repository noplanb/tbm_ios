//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSecretScreenView.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMDebugData.h"
#import "UIButton+TBMRoundedButton.h"

@interface TBMSecretScreenView ()

@property(nonatomic, copy) TBMDebugData *data;

/**
* Version - CONFIG_VERSION_STRING CONFIG_VERSION_NUMBER
*/
@property(nonatomic, strong) UILabel *versionLabel;

/* User
* firstName
* lastName
* mobileNumber
*/
@property(nonatomic, strong) UILabel *firstNameLabel;
@property(nonatomic, strong) UILabel *lastNameLabel;
@property(nonatomic, strong) UILabel *mobileNumberLabel;


/*
* Debug Mode - Toggle switch: on | off
* Sets CONFIG_DEBUG_MODE
* Default CONFIG_DEBUG_MODE == NO
* Persisted so that if set to yes it is remembered if app is killed in the task manager and restarted.
* You might look at how S3 credentials are persistently stored and use the same mechanism. Or you may have a better idea I am open to learning about.
*/
@property(nonatomic, strong) UILabel *debugModeLabel;
@property(nonatomic, strong) UISwitch *debugModeSwitch;

/*
* Crash - Button
*   on tap: causes an exception to be thrown.
*/
@property(nonatomic, strong) UIButton *crashButton;

/* Server
*  3 way selector: Prod | Stage | Other
*   When other is selected a text entry field is revealed where user can enter an http address for an arbitrary server.
*   - Default  Prod
*   - Persisted so it is recalled after app shutdown.
*/
@property(nonatomic, strong) UISegmentedControl *serverSegmentedControl;

/*
* Log - Button
* Tap - opens log screen that was previously accessible by a long press on the Zazo logo on the homeview.
*/
@property(nonatomic, strong) UIButton *logButton;

/*
* State - Button
*    Tap - opens a state screen that shows current state of the app. This is described in a separate document.
*    Back button on the state screen dismisses it and returns to the secret debug screen.
*/
@property(nonatomic, strong) UIButton *stateButton;


@end

@implementation TBMSecretScreenView {

}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {

    CGFloat topOffset = 60.0f; // navigation bar
    CGFloat vertMargin = 8.0f;
    CGFloat horzMargin = 8.0f;

    CGFloat fullWidth = CGRectGetWidth(self.bounds);
    CGFloat halfWidth = (fullWidth / 2) - (horzMargin);

    CGFloat labelHeight = 24.f;
    CGFloat buttonHeight = 38.f;

    self.backgroundColor = [UIColor whiteColor];

    //Version label
    self.versionLabel.frame = CGRectMake(horzMargin, topOffset + ((vertMargin + labelHeight) * 1), fullWidth - horzMargin, labelHeight);
    [self addSubview:self.versionLabel];

    CGFloat lineTop = topOffset + ((vertMargin + labelHeight) * 2);
    //Version label
    self.firstNameLabel.frame = CGRectMake(horzMargin, lineTop, fullWidth - horzMargin, labelHeight);
    [self addSubview:self.firstNameLabel];
    lineTop += labelHeight;
    lineTop += vertMargin;

    //Last Name label
    self.lastNameLabel.frame = CGRectMake(horzMargin, lineTop, fullWidth - horzMargin, labelHeight);
    [self addSubview:self.lastNameLabel];
    lineTop += labelHeight;
    lineTop += vertMargin;

    //mobileNumber label
    self.mobileNumberLabel.frame = CGRectMake(horzMargin, lineTop, fullWidth - horzMargin, labelHeight);
    [self addSubview:self.mobileNumberLabel];
    lineTop += labelHeight;
    lineTop += vertMargin;

    //Server state control
    lineTop += 10.f;
    self.serverSegmentedControl.frame = CGRectMake(horzMargin, lineTop, fullWidth - horzMargin - horzMargin, buttonHeight);
    [self addSubview:self.serverSegmentedControl];
    lineTop += buttonHeight;
    lineTop += vertMargin;

    //debugModeSwitch
    self.debugModeLabel.frame = CGRectMake(horzMargin, lineTop + 5, halfWidth - horzMargin, labelHeight);
    [self addSubview:self.debugModeLabel];

    self.debugModeSwitch.frame = CGRectMake(horzMargin + halfWidth, lineTop, halfWidth - horzMargin, labelHeight);
    [self.debugModeSwitch setOn:YES animated:NO];
    [self addSubview:self.debugModeSwitch];

    lineTop += labelHeight;
    lineTop += vertMargin;

    //crash & log  buttons
    lineTop += 10.f;
    self.crashButton.frame = CGRectMake(horzMargin, lineTop, halfWidth - horzMargin, buttonHeight);
    [self addSubview:self.crashButton];

    self.logButton.frame = CGRectMake(horzMargin * 2 + halfWidth, lineTop, halfWidth - horzMargin, buttonHeight);
    [self addSubview:self.logButton];

    [self updateUserInterfaceWithData];
    lineTop += buttonHeight;
    lineTop += vertMargin;

    //State button
    lineTop += 10.f;
    self.stateButton.frame = CGRectMake(horzMargin, lineTop, fullWidth - (horzMargin * 2), buttonHeight);
    [self addSubview:self.stateButton];

}


- (void)updateUserInterfaceWithData {
    self.versionLabel.text = @"Version 2.0";
    self.firstNameLabel.text = @"firstNameLabel 2.0";
    self.lastNameLabel.text = @"lastNameLabel 2.0";
    self.mobileNumberLabel.text = @"mobileNumberLabel 2.0";
    self.serverSegmentedControl.selectedSegmentIndex = 1;
}

#pragma mark - Actions

- (void)debugModeSwitchAction:(id)sender {
    [self.eventHandler debugSwitchDidChangeTo:self.debugModeSwitch.on];
}

- (void)crashButtonAction:(id)sender {
    [self.eventHandler crashButtonDidPress];
}

- (void)logButtonAction:(id)sender {
    [self.eventHandler logButtonDidPress];
}

- (void)stateButtonAction:(id)sender {
    [self.eventHandler stateButtonDidPress];
}

- (void)serverSegmentedControlAction:(id)sender {
    [self.eventHandler serverSegmentedControlDidChangeTo:self.serverSegmentedControl.selectedSegmentIndex];
}

#pragma mark - Autoinitializers

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
    }
    return _versionLabel;
}

- (UILabel *)firstNameLabel {
    if (!_firstNameLabel) {
        _firstNameLabel = [[UILabel alloc] init];
    }
    return _firstNameLabel;
}

- (UILabel *)lastNameLabel {
    if (!_lastNameLabel) {
        _lastNameLabel = [[UILabel alloc] init];
    }
    return _lastNameLabel;
}

- (UILabel *)mobileNumberLabel {
    if (!_mobileNumberLabel) {
        _mobileNumberLabel = [[UILabel alloc] init];
    }
    return _mobileNumberLabel;
}

- (UILabel *)debugModeLabel {
    if (!_debugModeLabel) {
        _debugModeLabel = [[UILabel alloc] init];
        _debugModeLabel.text = @"Debug mode";
    }
    return _debugModeLabel;
}

- (UISwitch *)debugModeSwitch {
    if (!_debugModeSwitch) {
        _debugModeSwitch = [[UISwitch alloc] init];
        [_debugModeSwitch addTarget:self action:@selector(debugModeSwitchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _debugModeSwitch;
}

- (UIButton *)crashButton {
    if (!_crashButton) {
        _crashButton = [[UIButton alloc] init];
        [_crashButton setupRoundedButtonWithColor:[UIColor blueColor]];
        [_crashButton setTitle:@"Crash" forState:UIControlStateNormal];
        [_crashButton addTarget:self action:@selector(crashButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _crashButton;
}

- (UISegmentedControl *)serverSegmentedControl {
    if (!_serverSegmentedControl) {
        _serverSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"PROD",@"DEV",@"CUSTOM"]];
        [_serverSegmentedControl addTarget:self
                             action:@selector(serverSegmentedControlAction:)
                   forControlEvents:UIControlEventValueChanged];
    }
    return _serverSegmentedControl;
}

- (UIButton *)logButton {
    if (!_logButton) {
        _logButton = [[UIButton alloc] init];
        [_logButton setupRoundedButtonWithColor:[UIColor blueColor]];
        [_logButton setTitle:@"Logs" forState:UIControlStateNormal];
        [_logButton addTarget:self action:@selector(logButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _logButton;
}

- (UIButton *)stateButton {
    if (!_stateButton) {
        _stateButton = [[UIButton alloc] init];
        [_stateButton setupRoundedButtonWithColor:[UIColor blueColor]];
        [_stateButton setTitle:@"State" forState:UIControlStateNormal];
        [_stateButton addTarget:self action:@selector(stateButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _stateButton;
}


@end