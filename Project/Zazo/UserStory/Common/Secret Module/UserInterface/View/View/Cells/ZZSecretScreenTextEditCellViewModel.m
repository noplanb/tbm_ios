//
//  ZZSecretScreenTextEditCellViewModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/31/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretScreenTextEditCellViewModel.h"

@implementation ZZSecretScreenTextEditCellViewModel

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.text = textField.text;
    [self.delegate viewModel:self updatedTextValue:self.text];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.text = textField.text;
    [self.delegate viewModel:self updatedTextValue:self.text];
}

@end
