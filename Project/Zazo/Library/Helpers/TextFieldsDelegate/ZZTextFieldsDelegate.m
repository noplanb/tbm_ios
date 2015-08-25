//
//  ZZTextFieldsDelegate.m
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZTextFieldsDelegate.h"

@interface ZZTextFieldsDelegate () <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray* textFields;

@end

@implementation ZZTextFieldsDelegate

- (instancetype)init
{
    if (self = [super init])
    {
        self.textFields = [NSMutableArray new];
    }
    return self;
}

- (void)addTextFieldsWithArray:(NSArray*)textFields
{
    [self.textFields removeAllObjects];
    [self.textFields addObjectsFromArray:textFields];
    [self _startObserve];
}

- (void)_startObserve
{
    NSInteger textFieldCount = self.textFields.count;
    [self.textFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       if ([obj isKindOfClass:[UITextField class]])
       {
           UITextField* textField = (UITextField*)obj;
           textField.delegate = self;
           textField.returnKeyType =
           idx < textFieldCount - 1 ? UIReturnKeyNext : UIReturnKeyDone;
       }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
    if (index == self.textFields.count - 1)
    {
        [textField resignFirstResponder];
    }
    else if (index < self.textFields.count - 1)
    {
        UITextField* nextTextField = (UITextField*)self.textFields[index + 1];
        [nextTextField becomeFirstResponder];
    }
    
    return YES;
}



@end
