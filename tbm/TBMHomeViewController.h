//
//  TBMHomeViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMGridViewController.h"
#import "TBMBenchViewController.h"
#import "TBMGridDelegate.h"
#import "TBMHomeModuleInterface.h"

@protocol TBMEventsFlowModuleInterface;

@interface TBMHomeViewController : UIViewController <TBMBenchViewControllerDelegate, TBMGridDelegate, TBMHomeModuleInterface>

@property(nonatomic) TBMGridViewController *gridViewController;

+ (TBMHomeViewController *)existingInstance;

- (void)applicationWillSwitchToSMS;

//TODO:Move to module interface after refactoring
- (void)setupEvensFlowModule:(id <TBMEventsFlowModuleInterface>)eventsFlowModule;


@end
