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
#import "ZZGridUIConstants.h"
#import "ZZHintsModelGenerator.h"
#import "ZZHintsDomainModel.h"

@interface ZZGridActionHandler ()

@property (nonatomic, strong) ZZHintsController* hintsController;
@property(nonatomic, strong) NSSet* hints;

@property(nonatomic, strong) ZZHintsDomainModel* hint;
@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupHints];
    }
    return self;
}

- (void)setupHints
{
    NSMutableSet* hints = [NSMutableSet set];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeSendZazo]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypePressAndHoldToRecord]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeGiftIsWaiting]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeTapToSwitchCamera]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeWelcomeNudgeUser]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeWelcomeFor]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeAbortRecording]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeEarpieceUsage]];
    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeSpin]];
    self.hints = hints;
}


- (void)handleEvent:(ZZGridActionEventType)event
{
    __block ZZHintsDomainModel* hint;
    [self.hints enumerateObjectsUsingBlock:^(ZZHintsDomainModel* obj, BOOL* stop)
    {
        if (obj.condition && obj.condition(event))
        {
            hint = (!hint || hint.priority < obj.priority) ?  obj: hint;
        }
    }];

    if (hint && ![self.hint isEqual:hint]) {
        [self showHint:hint];
    }
}

- (void)showHint:(ZZHintsDomainModel*)hint
{


    // text becomes from model with type play or record

    ZZHintsDomainModel* currentHint = self.hintsController.hintModel;

    if (!currentHint) {
        self.hint = hint;
        [self.hint toggleStateTo:YES];
        [self.hintsController showHintWithModel:hint];
        return;
    }

    ZZHintsDomainModel* recordHint = [self _hintWithType:ZZHintsTypePressAndHoldToRecord];
    ZZHintsDomainModel* playHint = [self _hintWithType:ZZHintsTypeTapToPlay];
    ZZHintsDomainModel* hintForAppend;

    if (currentHint.type == recordHint.type) {
        hintForAppend = playHint;
    }

    if (currentHint.type == playHint.type) {
        hintForAppend = recordHint;
    }

    if (hintForAppend) {
        currentHint.title = [NSString stringWithFormat:@"%@\n%@",currentHint.title,hintForAppend.title];
        [hintForAppend toggleStateTo:YES];
    }

}

- (void)welcomeZazoSentSuccessfully // welcome zazo - message to user that we invited, and no other messages from this friend was not received
{
    if ([ZZGridActionDataProvider unlockNextFeature] ) {
        NSUInteger unlockedFeature = [ZZGridActionDataProvider lastUnlockedFeature];
        [self.delegate unlockFeature:unlockedFeature];
    }
     // TODO: (FEATURES) show message, unlock UI
    [self handleEvent:ZZGridActionEventTypeMessageDidSend];
}

- (void)dismissedHintWithType:(ZZHintsType)type
{
    switch (type)
    {
        case ZZHintsTypeTapToSwitchCamera:
        case ZZHintsTypeAbortRecording:
        case ZZHintsTypeEditFriends:
        case ZZHintsTypeEarpieceUsage:
        case ZZHintsTypeSpin:
            [self handleEvent:ZZGridActionEventTypeUsageHintDidDismiss];
            break;
        default:
            break;
    }
}


#pragma mark - Actions

//- (void)_handleGridBecomeActive
//{ // TODO: (HINTS) Remove
//    NSInteger numberFilledGrids = [ZZGridActionDataProvider numberOfUsersOnGrid];
//    NSInteger nextHintCellIndex = NSNotFound;
//    if (numberFilledGrids < 8) // TODO: constants
//    {
//        nextHintCellIndex = kNextGridElementIndexFromCount(numberFilledGrids); // to get index from count
//    }
//    
//    if (nextHintCellIndex != NSNotFound)
//    {
////        [self.hintsController showHintWithType:ZZHintsTypeSendZazo
////                                    focusFrame:[self.userInterface focusFrameForIndex:nextHintCellIndex]
////                                     withIndex:nextHintCellIndex
////                               formatParameter:@""];  // TODO: move format parameter to domain model
//    }
//}


//- (NSDictionary*)_indexMap
//{ // TODO: (HINTS) Remove or get a reason to do not
//    return @{@(0) : @(5)}; // TODO: fill other
//}

#pragma mark - Private

//- (void)_showUnlockAnotherFeatureToast
//{ // TODO: (HINTS) Remove, cause it is implemented in next feature(gift) hint
//    ZZToastMessageBuilder *toastBuilder = [ZZToastMessageBuilder new];
//    NSString* title = NSLocalizedString(@"toast-hints.zazo-someone-else.title", @"");
//    NSString* message = NSLocalizedString(@"toast-hints.zazo-someone-else.message", @"");
//    
//    [toastBuilder showToastWithTitle:title andMessage:message];
//}

- (ZZHintsDomainModel*)_hintWithType:(ZZHintsType)hintType
{
    __block ZZHintsDomainModel* hint;
    [self.hints enumerateObjectsUsingBlock:^(ZZHintsDomainModel* obj, BOOL* stop)
    {
        if (obj.type == hintType)
        {
            hint = obj;
            stop = YES;
        }
    }];
    return hint;
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
