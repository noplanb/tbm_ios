//
//  ZZAPIRoutes.m
//  Zazo
//
//  Created by Server on 27/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZAPIRoutes.h"

static const struct
{
    __unsafe_unretained NSString *production;
    __unsafe_unretained NSString *staging;
} ZZAPIBaseURLsList = {
    .production = @"http://prod.zazoapp.com",
    .staging = @"http://staging.zazoapp.com",
};

NSString *APIBaseURL()
{
    ZZConfigServerState state = [ZZStoredSettingsManager shared].serverEndpointState;
    
    NSString *apiURLString;
    
    switch (state)
    {
        case ZZConfigServerStateDeveloper:
        {
            apiURLString = ZZAPIBaseURLsList.staging;
        }
            break;
        case ZZConfigServerStateCustom:
        {
            apiURLString = [ZZStoredSettingsManager shared].serverURLString;
        }
            break;
        default:
        {
            apiURLString = ZZAPIBaseURLsList.production;
        }
            break;
    }
    if (ANIsEmpty(apiURLString))
    {
        apiURLString = ZZAPIBaseURLsList.production;
    }
#ifdef STAGESERVER
    apiURLString = ZZAPIBaseURLsList.staging;
#endif
    
    return apiURLString;
}
