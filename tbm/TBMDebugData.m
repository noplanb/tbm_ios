//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDebugData.h"
#import "TBMConfig.h"
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
    NSArray *versionParts = @[CONFIG_VERSION_STRING,@"(",CONFIG_VERSION_NUMBER,@")"];
    self.version = [versionParts componentsJoinedByString:@" "];
    TBMUser *user = [TBMUser getUser];

    self.firstName = user.firstName;
    self.lastName = user.lastName;
    self.mobileNumber = user.mobileNumber;

    self.serverState = [TBMConfig serverState];
    self.debugMode = [TBMConfig configDebugMode];
}

- (NSString *)debugDescription {
    NSMutableString *description = [@"* " mutableCopy];

    if (self.version) {
        [description appendString:@"Version: "];
        [description appendString:self.version];
        [description appendString:@"\n * "];
    }

    if (self.firstName) {
        [description appendString:@"First Name: "];
        [description appendString:self.firstName];
        [description appendString:@"\n * "];
    }

    if (self.lastName) {
        [description appendString:@"Last Name: "];
        [description appendString:self.lastName];
        [description appendString:@"\n * "];
    }

    if (self.mobileNumber) {
        [description appendString:@"Phone: "];
        [description appendString:self.mobileNumber];
        [description appendString:@"\n * "];
    }

    if (self.serverState == TBMServerStateCustom) {
        [description appendString:@"Server State: Custom"];
    } else if (self.serverState == TBMServerStateDeveloper){
        [description appendString:@"Server State: Development"];
    } else {
        [description appendString:@"Server State: Production"];
    }

    [description appendString:@"\n * "];

    if (self.debugMode == TBMConfigDebugModeOn) {
        [description appendString:@"Debug mode: ON"];
    } else {
        [description appendString:@"Debug mode: OFF"];
    }
    [description appendString:@"\n"];
    return (NSString *) description;
}

@end