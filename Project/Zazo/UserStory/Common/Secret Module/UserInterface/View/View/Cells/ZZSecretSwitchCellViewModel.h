//
//  ZZSecretSwitchCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretEnums.h"

@protocol ZZSecretSwitchCellViewModelDelegate <NSObject>

- (void)switchValueChangedForType:(ZZSecretSwitchCellType)type;

@end

@interface ZZSecretSwitchCellViewModel : NSObject

@property (nonatomic, weak) id<ZZSecretSwitchCellViewModelDelegate> delegate;
@property (nonatomic, assign) ZZSecretSwitchCellType type;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) BOOL switchState;

- (void)switchValueChanged;

@end
