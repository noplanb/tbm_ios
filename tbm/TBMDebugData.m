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
    self.debugMode = [TBMConfig deviceDebugMode];
}
@end