//
//  ZZGridActionHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandler.h"
#import "ZZHintsController.h"
#import "ZZVideoRecorder.h"
#import "ZZBaseEventHandler.h"
#import "ZZInviteEventHandler.h"
#import "ZZPlayEventHandler.h"
#import "ZZSentMessgeEventHandler.h"
#import "ZZViewedMessageEventHandler.h"
#import "ZZRecordEventHandler.h"
#import "ZZInviteSomeoneElseEventHandler.h"
#import "ZZSentWelcomeEventHandler.h"
#import "ZZFronCameraFeatureEventHandler.h"
#import "ZZAbortRecordingFeatureEventHandler.h"
#import "ZZDeleteFriendsFeatureEventHandler.h"
#import "ZZEarpieceFeatureEventHandler.h"
#import "ZZSpinFeatureEventHandler.h"
#import "ZZFeatureEventObserver.h"
#import "TBMFeatureUnlockDialogView.h"
#import "TBMNextFeatureDialogView.h"
#import "ZZStoredSettingsManager.h"

@interface ZZGridActionHandler ()
        <
        ZZHintsControllerDelegate,
        ZZFeatureEventObserverDelegate,
        ZZEventHandlerDelegate
        >

@property (nonatomic, strong) ZZHintsController *hintsController;
@property (nonatomic, strong) ZZInviteEventHandler *startEventHandler;
@property (nonatomic, strong) ZZFeatureEventObserver *featureEventObserver;
@property (nonatomic, assign) NSInteger lastActionIndex;

@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _initializeEventHandlers];
        [self _setupFeatureEventObserver];
    }
    return self;
}

- (void)_setupFeatureEventObserver
{
    self.featureEventObserver = [ZZFeatureEventObserver new];
    self.featureEventObserver.delegate = self;
}


#pragma mark - Initilize event handlers

- (void)_initializeEventHandlers
{
    NSInteger startEventIndex = 0;
    __block NSMutableArray *eventHandlers = [NSMutableArray array];

    [[self _eventHandlers] enumerateObjectsUsingBlock:^(NSString *_Nonnull className, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx == startEventIndex)
        {
            self.startEventHandler = [NSClassFromString(className) new];
            [eventHandlers addObject:self.startEventHandler];
        }
        else
        {
            ZZBaseEventHandler *eventHandler = [NSClassFromString(className) new];
            [eventHandlers addObject:eventHandler];
        }
    }];

    [self _configureDelegatesAndNextHandlerForHandlers:eventHandlers];
}

- (void)_configureDelegatesAndNextHandlerForHandlers:(NSArray *)handlers
{
    NSInteger nextEventHandlerIndex = 1;

    for (NSInteger i = 0; i < handlers.count; i++)
    {
        ZZBaseEventHandler *eventHandler = handlers[i];
        eventHandler.delegate = self;
        if ((i + nextEventHandlerIndex) < handlers.count)
        {
            eventHandler.eventHandler = handlers[i + nextEventHandlerIndex];
        }
    }
}


- (NSArray *)_eventHandlers
{
    return @[
            NSStringFromClass([ZZInviteEventHandler class]),
            NSStringFromClass([ZZPlayEventHandler class]),
            NSStringFromClass([ZZRecordEventHandler class]),
            NSStringFromClass([ZZSentMessgeEventHandler class]),
            NSStringFromClass([ZZViewedMessageEventHandler class]),
            NSStringFromClass([ZZInviteSomeoneElseEventHandler class]),
            NSStringFromClass([ZZSentWelcomeEventHandler class]),
            NSStringFromClass([ZZFronCameraFeatureEventHandler class]),
            NSStringFromClass([ZZAbortRecordingFeatureEventHandler class]),
            NSStringFromClass([ZZDeleteFriendsFeatureEventHandler class]),
            NSStringFromClass([ZZEarpieceFeatureEventHandler class]),
            NSStringFromClass([ZZSpinFeatureEventHandler class])
    ];
}


#pragma mark - Handle Events

- (void)handleEvent:(ZZGridActionEventType)event
          withIndex:(NSInteger)index
        friendModel:(ZZFriendDomainModel *)friendModel
{
    self.lastActionIndex = index;
    __block NSInteger actionIndex = index;

    if ([self _isAbleToShowHints])
    {
        [self.startEventHandler handleEvent:event model:friendModel withCompletionBlock:^(ZZHintsType type, ZZFriendDomainModel *model) {
            if (type != ZZHintsTypeNoHint)
            {
                if (type == ZZHintsTypeInviteSomeElseHint)
                {
                    actionIndex = 2;
                }


                [self _configureHintControllerWithHintType:type withModel:model index:actionIndex];
            }


            [self.featureEventObserver handleEvent:event withModel:model withIndex:actionIndex withCompletionBlock:^(BOOL isFeatureShowed) {
                if (!isFeatureShowed && type == ZZHintsTypeNoHint)
                {
                    [self _showNextFeatureHintIfNeeded];
                }
            }];
        }];
    }
}

- (void)updateFeaturesWithFriendsMkeys:(NSArray *)friendsMkeys
{
    [self.featureEventObserver updateFeaturesWithRemoteFriendMkeys:friendsMkeys];
}

- (void)_configureHintControllerWithHintType:(ZZHintsType)hintType withModel:(ZZFriendDomainModel *)model index:(NSInteger)index
{
    NSString *formatParametr = model.fullName;

    [self.hintsController showHintWithType:hintType
                                focusFrame:[self.userInterface focusFrameForIndex:index]
                                 withIndex:index
                                 withModel:model
                           formatParameter:formatParametr];

    UIView *view = [self.delegate presentedView];

    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[TBMFeatureUnlockDialogView class]])
        {
            [view bringSubviewToFront:obj];
            *stop = YES;
        }
    }];
}


#pragma mark - Hints Controller Delegate methods

- (void)hintWasDismissedWithType:(ZZHintsType)type
{
    if (type == ZZHintsTypeSentHint)
    {
        [self handleEvent:ZZGridActionEventTypeSentZazo withIndex:2 friendModel:nil];
    }

    else if (type == ZZHintsTypeInviteSomeElseHint)
    {
        [self _showNextFeatureHintIfNeeded];
    }

    else if ((type == ZZHintsTypeFrontCameraUsageHint ||
            type == ZZHintsTypeAbortRecordingUsageHint ||
            type == ZZHintsTypeDeleteFriendUsageHint ||
            type == ZZHintsTypeEarpieceUsageHint ||
            type == ZZHintsTypeSpinUsageHint) &&
            ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [TBMNextFeatureDialogView showNextFeatureDialogWithPresentedView:[self.delegate presentedView] completionBlock:^{

        }];
    }
}

- (void)_showNextFeatureHintIfNeeded
{
    if (![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [TBMNextFeatureDialogView showNextFeatureDialogWithPresentedView:[self.delegate presentedView] completionBlock:^{

        }];
    }
}

- (UIView *)hintPresentedView
{
    return [self.delegate presentedView];
}

- (void)showMenuTab
{
    [self.delegate showMenuTab];
}

- (void)showGridTab
{
    [self.delegate showGridTab];
}

#pragma mark - Feature Event Observer Delegate

- (void)showNextFeatureDialog
{
    [self _showNextFeatureHintIfNeeded];
}

- (void)handleUnlockFeatureWithType:(ZZGridActionFeatureType)type withIndex:(NSInteger)index friendModel:(ZZFriendDomainModel *)model
{
    switch (type)
    {
        case ZZGridActionFeatureTypeSwitchCamera:
        {
            NSInteger centerViewIndex = 4;
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.use-both-cameras", nil) withPresentedView:[self.delegate presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeFrontCameraFeatureUnlocked withIndex:centerViewIndex friendModel:model];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeSwitchCamera];
            }];

        }
            break;
        case ZZGridActionFeatureTypeAbortRec:
        {
            NSInteger middleRightIndex = 5;
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.abort-recording", nil) withPresentedView:[self.delegate presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeAbortRecordingFeatureUnlocked withIndex:middleRightIndex friendModel:model];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeAbortRec];
            }];

        }
            break;
        case ZZGridActionFeatureTypeDeleteFriend:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.delete-friend", nil) withPresentedView:[self.delegate presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeDeleteFriendsFeatureUnlocked withIndex:0 friendModel:model];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeDeleteFriend];
            }];

        }
            break;
        case ZZGridActionFeatureTypeEarpiece:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.listen-from-earpiece", nil) withPresentedView:[self.delegate presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeEarpieceFeatureUnlocked withIndex:5 friendModel:model];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeEarpiece];
            }];

        }
            break;
        case ZZGridActionFeatureTypeSpinWheel:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.spin-your-friends", nil) withPresentedView:[self.delegate presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeSpinUsageFeatureUnlocked withIndex:6 friendModel:model];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeSpinWheel];
            }];

        }
            break;

        default:
        {
        }
            break;
    }
}


- (void)hideHint
{
    [self.hintsController hideHintView];
}

#pragma mark - Event Handler Delegate

- (NSInteger)friendsNumberOnGrid
{
    return [self.delegate friendsCountOnGrid];
}


#pragma mark - IS ABLE SHOW HINTS

- (BOOL)_isAbleToShowHints
{
    BOOL isAble = NO;

    if (![[ZZVideoRecorder shared] isRecording] &&
            ![self.delegate isVideoPlayingNow])
    {
        isAble = YES;
    }

    return isAble;
}

- (void)resetLastHintAndShowIfNeeded
{
    if ([ZZStoredSettingsManager shared].wasPermissionAccess)
    {
        [ZZStoredSettingsManager shared].wasPermissionAccess = NO;
    }
    else if (![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = NO;
        [self.startEventHandler handleResetLastActionWithCompletionBlock:^(ZZGridActionEventType event, ZZFriendDomainModel *model) {
            [self handleEvent:event withIndex:self.lastActionIndex friendModel:model];
        }];
    }
}

#pragma mark - Lazy Load

- (ZZHintsController *)hintsController
{
    if (!_hintsController)
    {
        _hintsController = [ZZHintsController new];
        _hintsController.delegate = self;
        _hintsController.frameOffset = CGPointMake(0, 20);
    }
    return _hintsController;
}

@end
