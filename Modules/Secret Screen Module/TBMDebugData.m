//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDebugData.h"
#import "TBMUser.h"

@implementation TBMDebugData {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self fillData];
    }
    return self;
}

- (void)fillData {
    NSArray *versionParts = @[CONFIG_VERSION_STRING, @"(", CONFIG_VERSION_NUMBER, @")"];
    self.version = [versionParts componentsJoinedByString:@" "];
    TBMUser *user = [TBMUser getUser];

    self.firstName = user.firstName;
    self.lastName = user.lastName;
    self.mobileNumber = user.mobileNumber;

    self.serverState = [TBMConfig serverState];
    self.serverAddress = [TBMConfig serverURL];
    self.debugMode = [TBMConfig configDebugMode];
    self.dispatchType = [TBMDispatch dispatchType];
}


void append(NSMutableString *description, NSString *title, NSString *value) {
    [description appendString:title];
    if (value) {
        [description appendString:value];
    }
    [description appendString:@"\n * "];
}

- (NSString *)debugDescription {
    NSMutableString *description = [@"\n * DEBUG SCREEN DATA * * * * * * \n * " mutableCopy];

    append(description, @"Version: ", self.version);
    append(description, @"First Name: ", self.firstName);
    append(description, @"Last Name: ", self.lastName);
    append(description, @"Phone: ", self.mobileNumber);

    if (self.debugMode == TBMConfigDebugModeOn) {
        append(description, @"Debug mode: ", @"ON");
    } else {
        [description appendString:@"Debug mode: OFF"];
    }

    if (self.serverState == TBMServerStateCustom) {
        append(description, @"Server State: ", @"Custom");
    } else if (self.serverState == TBMServerStateDeveloper) {
        append(description, @"Server State: ", @"Development");
    } else {
        append(description, @"Server State: ", @"Production");
    }

    append(description, @"Server address: ", self.serverAddress);
    
    append(description, @"Dispatch Type: ", (self.dispatchType == TBMDispatchTypeSDK)?@"RollBar SDK":@"Server");

    [description appendString:@"\n * * * * * * * * * * * * * * * * * * * * * * * * \n"];
    return (NSString *) description;
}


@end