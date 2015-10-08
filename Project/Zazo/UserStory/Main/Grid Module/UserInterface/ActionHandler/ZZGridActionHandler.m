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


@interface ZZGridActionHandler () <ZZHintsControllerDelegate>

@property (nonatomic, strong) ZZHintsController* hintsController;
@property(nonatomic, strong) NSSet* hints;

@property(nonatomic, strong, readonly) ZZHintsDomainModel* presentedHint;
@property(nonatomic, assign) ZZGridActionEventType filterEvent; //Filter multuply times of event throwing
@property (nonatomic, strong) ZZInviteEventHandler* startEventHandler;

@end

@implementation ZZGridActionHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _configureEventHandlers];
    }
    return self;
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
