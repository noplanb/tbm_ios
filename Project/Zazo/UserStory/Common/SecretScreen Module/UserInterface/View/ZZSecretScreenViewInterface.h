//
//  ZZSecretScreenViewInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZSettingsModel; // TODO: make a protocol

@protocol ZZSecretScreenViewInterface <NSObject>

- (void)updateCustomServerFieldToEnabled:(BOOL)isEnabled;
- (void)updateWithModel:(ZZSettingsModel*)model;

@end
