//
//  ZZGridActionHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandler.h"
#import "ZZGridActionDataProvider.h"
#import "ZZHintsController.h"
#import "ZZHintsModelGenerator.h"
#import "ZZHintsDomainModel.h"
#import "ZZGridUIConstants.h"
#import "ZZVideoRecorder.h"

@interface ZZGridActionHandler ()

@property (nonatomic, strong) ZZHintsController* hintsController;
@property(nonatomic, strong) NSSet* hints;

@property(nonatomic, strong, readonly) ZZHintsDomainModel* presentedHint;
@property(nonatomic, assign) ZZGridActionEventType filterEvent; //Filter multuply times of event throwing
@end

@implementation ZZGridActionHandler


- (void)handleEvent:(ZZGridActionEventType)event
{
     //TODO: getCurrent index from delegate
    [self _configureHintControllerWithHintType:ZZHintsTypeInviteHint index:7];
    
}

- (void)_configureHintControllerWithHintType:(ZZHintsType)hintType index:(NSInteger)index
{
    [self.hintsController showHintWithType:hintType
                                focusFrame:[self.userInterface focusFrameForIndex:index]
                                 withIndex:index
                           formatParameter:@""];
}


#pragma mark - Lazy Load

- (ZZHintsController*)hintsController
{
    if (!_hintsController)
    {
        _hintsController = [ZZHintsController new];
    }
    return _hintsController;
}

@end
