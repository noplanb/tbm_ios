//
//  ZZSecretScreenInteractorIO.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZSecretScreenInteractorInput <NSObject>

- (void)loadData;
- (void)forceCrash;
- (void)dispatchData;
- (void)resetHints;
- (void)updateServerStateTo:(NSInteger)state;
- (void)updateDebugStateTo:(BOOL)isEnabled;
- (void)updateCustomServerEnpointValueTo:(NSString *)value;

@end


@protocol ZZSecretScreenInteractorOutput <NSObject>

- (void)dataLoaded:(id)data; // TODO: model type

@end