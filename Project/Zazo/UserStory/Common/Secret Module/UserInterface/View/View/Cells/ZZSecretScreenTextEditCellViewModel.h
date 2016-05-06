//
//  ZZSecretScreenTextEditCellViewModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/31/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZSecretScreenTextEditCellViewModel;

@protocol ZZSecretScreenTextEditCellViewModelDelegate <NSObject>

- (void)viewModel:(ZZSecretScreenTextEditCellViewModel *)viewModel updatedTextValue:(NSString *)textValue;

@end

@interface ZZSecretScreenTextEditCellViewModel : NSObject <UITextFieldDelegate>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, weak) id <ZZSecretScreenTextEditCellViewModelDelegate> delegate;
@property (nonatomic, weak) UITextField *textField;

@end
