//
//  ZZSecretScreenButtonView.m
//  Zazo
//
//  Created by ANODA on 23/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenButtonView.h"

@implementation ZZSecretScreenButtonView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self crashButton];
        [self logsButton];
        [self resetHintsButton];
        [self stateButton];
        [self dispatchButton];
    }
    return self;
}

- (ZZSecretScreenButton *)crashButton
{
    if (!_crashButton)
    {
        _crashButton = [ZZSecretScreenButton new];
        [_crashButton setTitle:NSLocalizedString(@"secret-controller.crash.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_crashButton];
        
        [_crashButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.height.equalTo(@(secretButtonHeight()));
            make.width.equalTo(@(secretButtonWidth()));
        }];
    }
    return _crashButton;
}

- (ZZSecretScreenButton *)logsButton
{
    if (!_logsButton)
    {
        _logsButton = [ZZSecretScreenButton new];
        [_logsButton setTitle:NSLocalizedString(@"secret-controller.logs.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_logsButton];
        
        [_logsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(self.crashButton.mas_height);
            make.width.equalTo(self.crashButton.mas_width);
        }];
    }
    
    return _logsButton;
}

- (ZZSecretScreenButton *)resetHintsButton
{
    if (!_resetHintsButton)
    {
        _resetHintsButton = [ZZSecretScreenButton new];
        [_resetHintsButton setTitle:NSLocalizedString(@"secret-controller.reset.hints.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_resetHintsButton];
        
        [_resetHintsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.crashButton.mas_bottom).with.offset(secretButtonPadding());
            make.left.equalTo(self);
            make.height.equalTo(self.crashButton.mas_height);
            make.width.equalTo(self.crashButton.mas_width);
        }];
    }
    
    return _resetHintsButton;
}

- (ZZSecretScreenButton *)stateButton
{
    if (!_stateButton)
    {
        _stateButton = [ZZSecretScreenButton new];
        [_stateButton setTitle:NSLocalizedString(@"secret-controller.state.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_stateButton];
        
        [_stateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.logsButton.mas_bottom).with.offset(secretButtonPadding());
            make.right.equalTo(self);
            make.height.equalTo(self.crashButton.mas_height);
            make.width.equalTo(self.crashButton.mas_width);
        }];
    }
    
    return _stateButton;
}

- (ZZSecretScreenButton *)dispatchButton
{
    if (!_dispatchButton)
    {
        _dispatchButton = [ZZSecretScreenButton new];
         [_dispatchButton setTitle:NSLocalizedString(@"secret-controller.dispatch.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_dispatchButton];
        
        [_dispatchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.stateButton.mas_bottom).with.offset(secretButtonPadding());
            make.height.equalTo(self.crashButton.mas_height);
        }];
    }
    return _dispatchButton;
}


@end
