//
//  ZZSecretScreenView.m
//  Zazo
//
//  Created by ANODA on 21/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenView.h"
#import "ZZSecretScreenViewSizes.h"

static NSInteger const kDebugSwitchLeftPadding = 20;
static NSInteger const kDebugSwitchWith = 60;
static NSInteger const kDebugSwitchHeight = 40;

@interface ZZSecretScreenView ()

@property (nonatomic, strong) UILabel* debugLabel;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;

@end

@implementation ZZSecretScreenView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self labelsInfoView];
        [self serverTypeControl];
        [self debugLabel];
        [self debugModeSwitch];
        [self buttonView];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
        [self addGestureRecognizer:self.tapRecognizer];
        
    }
    return self;
}

- (ZZSecretLabelsInfoView *)labelsInfoView
{
    if (!_labelsInfoView)
    {
        _labelsInfoView = [ZZSecretLabelsInfoView new];
        [self addSubview:_labelsInfoView];
        
        [_labelsInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.right.equalTo(self);
            make.height.equalTo(@(secretLabelInfoHeight()));
        }];
    }
    
    return _labelsInfoView;
}

- (UISegmentedControl *)serverTypeControl
{
    if (!_serverTypeControl)
    {
        NSArray* items = @[NSLocalizedString(@"secret-controller.prodserver.title", nil),
                           NSLocalizedString(@"secret-controller.stageserver.title", nil),
                           NSLocalizedString(@"secret-controller.customserver.title", nil)];
        _serverTypeControl = [[UISegmentedControl alloc] initWithItems:items];
        _serverTypeControl.selectedSegmentIndex = 1;
        [self addSubview:_serverTypeControl];
        
        [_serverTypeControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.labelsInfoView.mas_bottom).with.offset(segmentControllTopPadding());
            make.left.equalTo(self).with.offset(labelLeftPadding());
            make.right.equalTo(self).with.offset(-labelLeftPadding());
            make.height.equalTo(@(segmentControllHeight()));
        }];
        
    }
    
    return _serverTypeControl;
}

- (UILabel *)debugLabel
{
    if (!_debugLabel)
    {
        _debugLabel = [UILabel new];
        _debugLabel.text = NSLocalizedString(@"secret-controller.debugmode.title", nil);
        [_debugLabel sizeToFit];
        [self addSubview:_debugLabel];
        
        [_debugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(labelLeftPadding());
            make.top.equalTo(self.serverTypeControl.mas_bottom).with.offset(debugModeLabelTopPadding());
        }];
        
    }
    
    return _debugLabel;
}

- (UISwitch *)debugModeSwitch
{
    if (!_debugModeSwitch)
    {
        _debugModeSwitch = [UISwitch new];
        [self addSubview:_debugModeSwitch];
        
        [_debugModeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.debugLabel.mas_right).with.offset(kDebugSwitchLeftPadding);
            make.top.equalTo(self.serverTypeControl.mas_bottom).with.offset(debugSwitchTopPadding());
            make.width.equalTo(@(kDebugSwitchWith));
            make.height.equalTo(@(kDebugSwitchHeight));
        }];
    }
    
    return _debugModeSwitch;
}

- (ZZSecretScreenButtonView *)buttonView
{
    if (!_buttonView)
    {
        _buttonView = [ZZSecretScreenButtonView new];
        [self addSubview:_buttonView];
        
        [_buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.debugModeSwitch.mas_bottom);
            make.bottom.equalTo(self);
            make.left.equalTo(self.serverTypeControl.mas_left);
            make.right.equalTo(self.serverTypeControl.mas_right);
        }];
    }
    
    return _buttonView;
}

#pragma mark - End Editing Action

- (void)endEditing
{
    [self endEditing:YES];
}

@end
