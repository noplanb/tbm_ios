//
//  TBMAlertControllerVisualStyle.h
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCAlertControllerVisualStyle.h"
#import "SDCAlertControllerDefaultVisualStyle.h"

@class SDCAlertControllerView;

@interface TBMAlertControllerVisualStyle : SDCAlertControllerDefaultVisualStyle <SDCAlertControllerVisualStyle>

@property (nonatomic, weak) SDCAlertControllerView *alertControllerView;

@end
