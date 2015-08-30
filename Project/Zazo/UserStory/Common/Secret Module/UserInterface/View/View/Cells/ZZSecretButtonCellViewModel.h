//
//  ZZSecretButtonCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretEnums.h"

@protocol ZZSecretButtonCellViewModelDelegate <NSObject>

- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type;

@end

@interface ZZSecretButtonCellViewModel : NSObject

@property (nonatomic, assign) ZZSecretButtonCellType type;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, weak) id<ZZSecretButtonCellViewModelDelegate> delegate;

- (void)buttonSelected;

@end
