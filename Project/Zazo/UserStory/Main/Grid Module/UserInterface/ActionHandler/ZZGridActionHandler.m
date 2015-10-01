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
//    [hints addObject:[ZZHintsModelGenerator generateHintModelForType:ZZHintsTypeTapToPlay]];
    
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
    if (event == self.filterEvent)
    {
        return;
    }
    
    

    if ([ZZVideoRecorder shared].isRecording)
    {
        return;
    }

    __block ZZHintsDomainModel* hint;
    [self.hints enumerateObjectsUsingBlock:^(ZZHintsDomainModel* obj, BOOL* stop)
    {
        if (obj.condition && obj.condition(event))
        {
            hint = (!hint || hint.priority < obj.priority) ?  obj: hint;
        }
    }];


    if (hint && !self.presentedHint.type != hint.type)
    {
        self.filterEvent = event;
        [self _applyHint:hint];
    }
}

- (void)_applyHint:(ZZHintsDomainModel*)hint
{
    if (!self.presentedHint) {
        self.hintsController.hintModel = hint;
    }
    else
    {
        [self _checkPlayAndRecordHintsForAppend];
    }

    [self _showHint];
}

- (void)_showHint
{
    self.filterEvent = ZZGridActionEventTypeGridNone;
    NSUInteger gridIndex = [self _gridIndexForHintType:self.presentedHint.type];
//    self.hint.arrowDirection = [ZZHintsDomainModel arrowDirectionForIndex:gridIndex];
    CGRect focusFrame = [self.userInterface focusFrameForIndex:kHintGridIndexFromFlowIndex(gridIndex)];
    [self.hintsController showHintWithModel:self.presentedHint forFocusFrame:focusFrame];
    [self.presentedHint toggleStateTo:YES];
}

- (NSUInteger)_gridIndexForHintType:(ZZHintsType)hintType
{
    switch (hintType)
    {
        case ZZHintsTypePressAndHoldToRecord:
        case ZZHintsTypeSendZazo:
        case ZZHintsTypeZazoSent:
        case ZZHintsTypeGiftIsWaiting:
        case ZZHintsTypeTapToSwitchCamera:
        case ZZHintsTypeWelcomeNudgeUser:
        case ZZHintsTypeWelcomeFor:
        case ZZHintsTypeAbortRecording:
        case ZZHintsTypeEditFriends:
        case ZZHintsTypeEarpieceUsage:
        case ZZHintsTypeSpin:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

- (void)_checkPlayAndRecordHintsForAppend
{
    ZZHintsDomainModel* presentedHint = self.presentedHint;
    ZZHintsDomainModel* recordHint = [self _hintWithType:ZZHintsTypePressAndHoldToRecord];
    ZZHintsDomainModel* playHint = [self _hintWithType:ZZHintsTypeTapToPlay];
    ZZHintsDomainModel* hintForAppend;

    if (presentedHint.type == recordHint.type) {
        hintForAppend = playHint;
    }

    if (presentedHint.type == playHint.type) {
        hintForAppend = recordHint;
    }

    if (hintForAppend) {
        presentedHint.title = [NSString stringWithFormat:@"%@\n%@", presentedHint.title, hintForAppend.title];
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
    [self handleEvent:ZZGridActionEventTypeOutgoingMessageDidSend];
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
    __block ZZHintsDomainModel* hint = nil;
    [self.hints enumerateObjectsUsingBlock:^(ZZHintsDomainModel* obj, BOOL* stop)
    {
        if (obj.type == hintType)
        {
            hint = obj;
            *stop = YES;
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

- (ZZHintsDomainModel*)presentedHint
{
    return self.hintsController.hintModel;
}


@end
