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


@interface ZZGridActionHandler () <ZZHintsControllerDelegate, ZZFeatureEventObserverDelegate>

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
    ZZPlayEventHandler* playEventHandler = [ZZPlayEventHandler new];
    ZZRecordEventHandler* recordEventHandler = [ZZRecordEventHandler new];
    ZZSentMessgeEventHandler* sentMessageEventHandler = [ZZSentMessgeEventHandler new];
    ZZViewedMessageEventHandler* viewedmessageEventHandler = [ZZViewedMessageEventHandler new];
    ZZInviteSomeoneElseEventHandler* inviteSomeoneElseEventHandler = [ZZInviteSomeoneElseEventHandler new];
    ZZSentWelcomeEventHandler* sentWelcomeEventHandler = [ZZSentWelcomeEventHandler new];
    ZZFronCameraFeatureEventHandler* frontCameraEventHandler = [ZZFronCameraFeatureEventHandler new];
    ZZAbortRecordingFeatureEventHandler* abortRecordingEventHandler = [ZZAbortRecordingFeatureEventHandler new];
    ZZDeleteFriendsFeatureEventHandler* deleteFriendEventHandler = [ZZDeleteFriendsFeatureEventHandler new];
    ZZEarpieceFeatureEventHandler* earpieceEventHandler = [ZZEarpieceFeatureEventHandler new];
    ZZSpinFeatureEventHandler* spinFeatureEventHandler = [ZZSpinFeatureEventHandler new];
    
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
    id model = [self.delegate modelAtIndex:index];
    if (model)
    {
        model = [model isKindOfClass:[ZZGridCellViewModel class]] ? model : nil;
    
    }
    
    [self.startEventHandler handleEvent:event model:model withCompletionBlock:^(ZZHintsType type, ZZGridCellViewModel *model) {
       if (type != ZZHintsTypeNoHint)
       {
           [self _configureHintControllerWithHintType:type withModel:model index:index];
       }
    }];
    
    [self.featureEventObserver handleEvent:event withModel:model withIndex:index];
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
}

- (UIView *)hintPresetedView
{
   return [self.userInterface presentedView];
}


#pragma mark - Feature Event Observer Delegate

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
