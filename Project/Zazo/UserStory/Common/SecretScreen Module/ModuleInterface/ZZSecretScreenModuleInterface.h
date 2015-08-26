//
//  ZZSecretScreenModuleInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZSecretScreenModuleInterface <NSObject>

- (void)dismissController;

#pragma mark - Events

- (void)forceCrash;
- (void)resetHints;
- (void)dispatchData;
- (void)presentLogsController;
- (void)presentStateController;

- (void)updateDebugModeStateTo:(BOOL)isEnabled;
- (void)updateServerStateTo:(NSInteger)state; // TODO: enum
- (void)updateCustomServerEnpointValueTo:(NSString*)value;

@end
