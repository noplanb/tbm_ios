//
//  ANSystemSettingsManager.h
//  Zazo
//
//  Created by ANODA on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ZZStoredSettingsManager : NSObject

typedef NS_ENUM(NSUInteger, ZZConfigServerState) {
    ZZConfigServerStateProduction = 0,
    ZZConfigServerStateDeveloper = 1,
    ZZConfigServerStateCustom = 2,
};


#pragma mark - Configutation

@property (nonatomic, strong) NSString* serverURLString;
@property (nonatomic, assign) BOOL debugModeEnabled;
@property (nonatomic, assign) ZZConfigServerState serverEndpointState;


#pragma mark - Hints

@property (nonatomic, assign) BOOL hintsDidStartPlay;
@property (nonatomic, assign) BOOL hintsDidStartRecord;

+ (instancetype)shared;

@end
