//
//  ZZSecretSwitchServerCell.m
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSwitchServerCell.h"
#import "ZZGrayBorderTextField.h"

static UIEdgeInsets const kSegmentInsets = {5, 5, 5, 5};

@interface ZZSecretSwitchServerCell ()

@property (nonatomic, strong) ZZGrayBorderTextField* apiURLTextField;
@property (nonatomic, strong) ZZSecretSwitchServerCellViewModel* currentModel;

@end

@implementation ZZSecretSwitchServerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self serverTypeControl];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(ZZSecretSwitchServerCellViewModel *)model
{
    self.currentModel = model;
    
}

#pragma mark - Lazy Load

- (ZZGrayBorderTextField *)apiURLTextField
{
    if (!_apiURLTextField)
    {
        _apiURLTextField = [ZZGrayBorderTextField new];
        _apiURLTextField.text = @"http://";
        _apiURLTextField.enabled = NO;
        
        [self.contentView addSubview:_apiURLTextField];
        
        [_apiURLTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView).with.insets(kSegmentInsets);
            make.height.equalTo(@44);
        }];
    }
    return _apiURLTextField;
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
        [self.contentView addSubview:_serverTypeControl];
        
        [_serverTypeControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.apiURLTextField);
            make.top.equalTo(self.apiURLTextField.mas_bottom).offset(5);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
    }
    return _serverTypeControl;
}

@end
