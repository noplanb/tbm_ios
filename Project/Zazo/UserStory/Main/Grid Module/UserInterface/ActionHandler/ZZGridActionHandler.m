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
#import "ZZGridCellViewModel.h"
#import "ZZFeatureEventObserver.h"
#import "TBMFeatureUnlockDialogView.h"
#import "TBMNextFeatureDialogView.h"


@interface ZZGridActionHandler ()
<
 ZZHintsControllerDelegate,
 ZZFeatureEventObserverDelegate,
 ZZEventHandlerDelegate
>

@property (nonatomic, strong) ZZHintsController* hintsController;
@property(nonatomic, strong) NSSet* hints;

@property(nonatomic, strong, readonly) ZZHintsDomainModel* presentedHint;
@property(nonatomic, assign) ZZGridActionEventType filterEvent; //Filter multuply times of event throwing
@property (nonatomic, strong) ZZInviteEventHandler* startEventHandler;
@property (nonatomic, strong) ZZFeatureEventObserver* featureEventObserver;

@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _configureEventHandlers];
        [self _setupFeatureEventObserver];
    }
    return self;
}

- (void)_setupFeatureEventObserver
{
    self.featureEventObserver = [ZZFeatureEventObserver new];
    self.featureEventObserver.delegate = self;
}

- (void)_configureEventHandlers
{
    //TODO: made initialization in enum [string from class]
    
    self.startEventHandler = [ZZInviteEventHandler new];
    self.startEventHandler.delegate = self;
    ZZPlayEventHandler* playEventHandler = [ZZPlayEventHandler new];
    playEventHandler.delegate = self;
    
    ZZRecordEventHandler* recordEventHandler = [ZZRecordEventHandler new];
    recordEventHandler.delegate = self;
   
    ZZSentMessgeEventHandler* sentMessageEventHandler = [ZZSentMessgeEventHandler new];
    sentMessageEventHandler.delegate = self;
   
    ZZViewedMessageEventHandler* viewedmessageEventHandler = [ZZViewedMessageEventHandler new];
    viewedmessageEventHandler.delegate = self;
    
    ZZInviteSomeoneElseEventHandler* inviteSomeoneElseEventHandler = [ZZInviteSomeoneElseEventHandler new];
    inviteSomeoneElseEventHandler.delegate = self;
    
    ZZSentWelcomeEventHandler* sentWelcomeEventHandler = [ZZSentWelcomeEventHandler new];
    sentWelcomeEventHandler.delegate = self;
    
    ZZFronCameraFeatureEventHandler* frontCameraEventHandler = [ZZFronCameraFeatureEventHandler new];
    frontCameraEventHandler.delegate = self;
    
    ZZAbortRecordingFeatureEventHandler* abortRecordingEventHandler = [ZZAbortRecordingFeatureEventHandler new];
    abortRecordingEventHandler.delegate = self;
    
    ZZDeleteFriendsFeatureEventHandler* deleteFriendEventHandler = [ZZDeleteFriendsFeatureEventHandler new];
    deleteFriendEventHandler.delegate = self;
    
    ZZEarpieceFeatureEventHandler* earpieceEventHandler = [ZZEarpieceFeatureEventHandler new];
    earpieceEventHandler.delegate = self;
    
    ZZSpinFeatureEventHandler* spinFeatureEventHandler = [ZZSpinFeatureEventHandler new];
    spinFeatureEventHandler.delegate = self;
    
    self.startEventHandler.eventHandler = playEventHandler;
    playEventHandler.eventHandler = recordEventHandler;
    recordEventHandler.eventHandler = sentMessageEventHandler;
    sentMessageEventHandler.eventHandler = viewedmessageEventHandler;
    viewedmessageEventHandler.eventHandler = inviteSomeoneElseEventHandler;
    inviteSomeoneElseEventHandler.eventHandler = sentWelcomeEventHandler;
    sentWelcomeEventHandler.eventHandler = frontCameraEventHandler;
    frontCameraEventHandler.eventHandler = abortRecordingEventHandler;
    abortRecordingEventHandler.eventHandler = deleteFriendEventHandler;
    deleteFriendEventHandler.eventHandler = earpieceEventHandler;
    earpieceEventHandler.eventHandler = spinFeatureEventHandler;
}


- (void)handleEvent:(ZZGridActionEventType)event withIndex:(NSInteger)index
{
    __block NSInteger actionIndex = index;
    if ([self _isAbleToShowHints])
    {
        
        id model = [self.delegate modelAtIndex:actionIndex];
        if (model)
        {
            model = [model isKindOfClass:[ZZGridCellViewModel class]] ? model : nil;
            
        }
        
        [self.startEventHandler handleEvent:event model:model withCompletionBlock:^(ZZHintsType type, ZZGridCellViewModel *model) {
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

- (void)_configureHintControllerWithHintType:(ZZHintsType)hintType withModel:(ZZGridCellViewModel*)model index:(NSInteger)index
{
    NSString* formatParametr = model.item.relatedUser.fullName;
    
    [self.hintsController showHintWithType:hintType
                                focusFrame:[self.userInterface focusFrameForIndex:index]
                                 withIndex:index
                           formatParameter:formatParametr];
}


#pragma mark - Hints Controller Delegate methods

- (void)hintWasDissmissedWithType:(ZZHintsType)type
{
    if (type == ZZHintsTypeSentHint)
    {
        [self handleEvent:ZZGridActionEventTypeSentZazo withIndex:2];
        
    }
    
    if (type == ZZHintsTypeInviteSomeElseHint)
    {
        [self _showNextFeatureHintIfNeeded];
    }
    
    if ((type == ZZHintsTypeFrontCameraUsageHint ||
        type == ZZHintsTypeAbortRecordingUsageHint ||
        type == ZZHintsTypeDeleteFriendUsageHint ||
         type == ZZHintsTypeEarpieceUsageHint ||
         type == ZZHintsTypeSpinUsageHint) &&
        ![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [TBMNextFeatureDialogView showNextFeatureDialogWithPresentedView:[self.userInterface presentedView] completionBlock:^{
            
        }];
    }
}

- (void)_showNextFeatureHintIfNeeded
{
    if (![ZZGridActionStoredSettings shared].spinHintWasShown)
    {
        [TBMNextFeatureDialogView showNextFeatureDialogWithPresentedView:[self.userInterface presentedView] completionBlock:^{
            
        }];
    }
}

- (UIView *)hintPresetedView
{
   return [self.userInterface presentedView];
}


#pragma mark - Feature Event Observer Delegate

- (void)showNextFeatureDialog
{
    [self _showNextFeatureHintIfNeeded];
}

- (void)handleUnlockFeatureWithType:(ZZGridActionFeatureType)type withIndex:(NSInteger)index
{
    switch (type)
    {
        case ZZGridActionFeatureTypeSwitchCamera:
        {
            NSInteger centerViewIndex = 4;
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.use-both-cameras", nil) withPresentedView:[self.userInterface presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeFrontCameraFeatureUnlocked withIndex:centerViewIndex];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeSwitchCamera];
            }];
            
        } break;
        case ZZGridActionFeatureTypeAbortRec:
        {
            NSInteger middleRightIndex = 5;
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.abort-recording", nil) withPresentedView:[self.userInterface presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeAbortRecordingFeatureUnlocked withIndex:middleRightIndex];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeAbortRec];
            }];
            
        } break;
        case ZZGridActionFeatureTypeDeleteFriend:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.delete-friend", nil) withPresentedView:[self.userInterface presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeDeleteFriendsFeatureUnlocked withIndex:0];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeDeleteFriend];
            }];
            
        } break;
        case ZZGridActionFeatureTypeEarpiece:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.listen-from-earpiece", nil) withPresentedView:[self.userInterface presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeEarpieceFeatureUnlocked withIndex:5];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeEarpiece];
            }];
            
        } break;
        case ZZGridActionFeatureTypeSpinWheel:
        {
            [TBMFeatureUnlockDialogView showFeatureDialog:NSLocalizedString(@"feature-alerts.spin-your-friends", nil) withPresentedView:[self.userInterface presentedView] completionBlock:^{
                [self handleEvent:ZZGridActionEventTypeSpinUsageFeatureUnlocked withIndex:6];
                [self.delegate unlockedFeature:ZZGridActionFeatureTypeSpinWheel];
            }];
            
        } break;
            
        default:
        {
        } break;
    }
}


#pragma mark - Event Handler Delegate

- (NSInteger)frinedsNumberOnGrid
{
    return [self.delegate friendsCountOnGrid];
}


#pragma mark - IS ABLE SHOW HINTS

- (BOOL)_isAbleToShowHints
{
    BOOL isAble = NO;
    
    if (![ZZVideoRecorder shared].isRecorderActive &&
        ![self.delegate isVideoPlayingNow])
    {
        isAble = YES;
    }
    
    return isAble;
}

#pragma mark - Lazy Load

- (ZZHintsController*)hintsController
{
    if (!_hintsController)
    {
        _hintsController = [ZZHintsController new];
        _hintsController.delegate = self;
    }
    return _hintsController;
}

@end
