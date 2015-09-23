//
//  ZZGridActionHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandler.h"
#import "ZZGridActionDataProvider.h"
#import "ZZToastMessageBuilder.h"
#import "ZZHintsController.h"
#import "ZZHintsConstants.h"

@interface ZZGridActionHandler ()

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature; //this property should load from data provider
@property (nonatomic, strong) ZZHintsController* hintsController;

@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)handleEvent:(ZZGridActionEventType)event
{
    switch (event)
    {
        case ZZGridActionEventTypeGridLoaded:
        {
            [self _handleGridBecomeActive];
        } break;
        default: break;
    }
}

- (void)welcomeZazoSentSuccessfully // welcome zazo - message to user that we invited, and no other messages from this friend was not received
{
    self.lastUnlockedFeature++;
    // store new value in data provider
    [self.delegate unlockFeature:self.lastUnlockedFeature]; // show message, unlock UI
    //
}

- (void)dismissedHintWithType:(ZZGridActionEventType)type
{

}


#pragma mark - Actions

- (void)_handleGridBecomeActive
{
    NSInteger numberFilledGrids = [ZZGridActionDataProvider numberOfUsersOnGrid];
    NSInteger nextHintCellIndex = NSNotFound;
    if (numberFilledGrids < 8) // TODO: constants
    {
        NSNumber* cellIndex = [self _indexMap][@(numberFilledGrids + 1)];
        if (cellIndex)
        {
            nextHintCellIndex = [cellIndex integerValue];
        }
    }
    
    if (nextHintCellIndex != NSNotFound)
    {
        [self.hintsController showHintWithType:ZZHintsTypeSendZazo
                                    focusFrame:[self.userInterface focusFrameForIndex:nextHintCellIndex]
                                     withIndex:nextHintCellIndex
                               formatParameter:@""];  // TODO: move format parameter to domain model
    }
}


- (NSDictionary*)_indexMap
{
    return @{@(0) : @(5)}; // TODO: fill other
}

#pragma mark - Private

- (void)_showUnlockAnotherFeatureToast
{
    ZZToastMessageBuilder *toastBuilder = [ZZToastMessageBuilder new];
    NSString* title = NSLocalizedString(@"toast-hints.zazo-someone-else.title", @"");
    NSString* message = NSLocalizedString(@"toast-hints.zazo-someone-else.message", @"");
    
    [toastBuilder showToastWithTitle:title andMessage:message];
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
