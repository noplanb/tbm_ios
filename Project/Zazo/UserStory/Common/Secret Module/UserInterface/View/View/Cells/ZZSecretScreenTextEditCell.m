//
//  ZZSecretScreenTextEditCell.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/31/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretScreenTextEditCell.h"

@interface ZZSecretScreenTextEditCell ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ZZSecretScreenTextEditCell

- (void)updateWithModel:(ZZSecretScreenTextEditCellViewModel *)model
{
    self.textField.text = [model text];
    self.textField.enabled = [model isEnabled];
    self.textField.delegate = model;
    model.textField = self.textField;
}


#pragma mark - Lazy Load

- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [UITextField new];
        [self.contentView addSubview:_textField];

        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).offset(20);
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    return _textField;
}

@end
