//
//  ZZApplicationPermissionsHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZApplicationPermissionsHandler : NSObject

+ (RACSignal *)checkApplicationPermissions;

@end
