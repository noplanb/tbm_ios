//
//  ZZSecretSwitchCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretValueCellViewModel.h"

@class ZZSecretSwitchCellViewModel;

@protocol ZZSecretSwitchCellViewModelDelegate <NSObject>

- (void)viewModel:(ZZSecretSwitchCellViewModel*)viewModel updatedSwitchValueTo:(BOOL)isEnabled;

@end

@interface ZZSecretSwitchCellViewModel : NSObject

@property (nonatomic, weak) id<ZZSecretSwitchCellViewModelDelegate> delegate;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) BOOL switchState;

- (void)switchValueChanged;

@end
