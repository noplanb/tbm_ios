//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDebugData.h"
#import "TBMUser.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"

@implementation TBMDebugData

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self fillData];
    }
    return self;
}

- (void)fillData
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    self.version = [NSString stringWithFormat:@"%@ (%@) - %@", version, buildNumber, kGlobalApplicationVersion];
    
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    self.firstName = user.firstName;
    self.lastName = user.lastName;
    self.mobileNumber = user.mobileNumber;

    self.serverState = [[ZZStoredSettingsManager shared] serverEndpointState];
    self.serverAddress = [ZZStoredSettingsManager shared].serverURLString;
    self.debugMode = [ZZStoredSettingsManager shared].debugModeEnabled;
}


void append(NSMutableString *description, NSString *title, NSString *value)
{
    [description appendString:title];
    if (value)
    {
        [description appendString:value];
    }
    [description appendString:@"\n * "];
}

- (NSString *)debugDescription
{
    NSMutableString *description = [@"\n * DEBUG SCREEN DATA * * * * * * \n * " mutableCopy];

    append(description, @"Version: ", self.version);
    append(description, @"First Name: ", self.firstName);
    append(description, @"Last Name: ", self.lastName);
    append(description, @"Phone: ", self.mobileNumber);

    if (self.debugMode)
    {
        append(description, @"Debug mode: ", @"ON");
    }
    else
    {
        [description appendString:@"Debug mode: OFF"];
    }

    if (self.serverState == ZZConfigServerStateCustom)
    {
        append(description, @"Server State: ", @"Custom");
    }
    else if (self.serverState == ZZConfigServerStateDeveloper)
    {
        append(description, @"Server State: ", @"Development");
    }
    else {
        append(description, @"Server State: ", @"Production");
    }

    append(description, @"Server address: ", self.serverAddress);

    [description appendString:@"\n * * * * * * * * * * * * * * * * * * * * * * * * \n"];
    return (NSString *) description;
}


@end