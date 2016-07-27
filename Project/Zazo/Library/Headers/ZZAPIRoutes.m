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
} ZZApiBaseURLsList = {
    .production = @"http://prod.zazoapp.com",
    .staging = @"http://staging.zazoapp.com",
};

NSString *apiBaseURL()
{
    ZZConfigServerState state = [ZZStoredSettingsManager shared].serverEndpointState;
    
    NSString *apiURLString;
    
    switch (state)
    {
        case ZZConfigServerStateDeveloper:
        {
            apiURLString = ZZApiBaseURLsList.staging;
        }
            break;
        case ZZConfigServerStateCustom:
        {
            apiURLString = [ZZStoredSettingsManager shared].serverURLString;
        }
            break;
        default:
        {
            apiURLString = ZZApiBaseURLsList.production;
        }
            break;
    }
    if (ANIsEmpty(apiURLString))
    {
        apiURLString = ZZApiBaseURLsList.production;
    }
#ifdef STAGESERVER
    apiURLString = ZZApiBaseURLsList.staging;
#endif
    
    return apiURLString;
}
