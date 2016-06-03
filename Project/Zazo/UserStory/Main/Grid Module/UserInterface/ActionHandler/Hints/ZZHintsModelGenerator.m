//
//  ZZHintsModelGenerator.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsModelGenerator.h"
#import "ZZHintsDomainModel.h"
#import "NSArray+ZZAdditions.h"

@implementation ZZHintsModelGenerator

+ (ZZHintsDomainModel *)generateHintModelForType:(ZZHintsType)hintType
{
    switch (hintType)
    {
        case ZZHintsTypeInviteHint:
            return [self _sendZazoModel];
            break;

        case ZZHintsTypeRecordHint:
            return [self _pressAndHoldToRecord];
            break;

        case ZZHintsTypeSentHint:
            return [self _zazoSent];
            break;

        case ZZHintsTypeGiftIsWaiting:
            return [self _giftIsWaiting];
            break;

        case ZZHintsTypeFrontCameraUsageHint:
            return [self _tapToSwitchCamera];
            break;

        case ZZHintsTypeWelcomeNudgeUser:
            return [self _welcomeNudgeUser];
            break;

        case ZZHintsTypeSendWelcomeHint:
            return [self _welcomeFor];
            break;

        case ZZHintsTypeAbortRecordingUsageHint:
            return [self _abortRecording];
            break;

        case ZZHintsTypeDeleteFriendUsageHint:
            return [self _editFriends];
            break;

        case ZZHintsTypeEarpieceUsageHint:
            return [self _earpieceUsage];
            break;
            
        case ZZHintsTypeFullscreenUsageHint:
            return [self _fullscreenHintModel];
            break;
            
        case ZZHintsTypePlaybackControlsUsageHint:
            return [self _playbackControlsHintModel];
            break;
            
        case ZZHintsTypeSpinUsageHint:
            return [self _spin];
            break;
            
        case ZZHintsTypePlayHint:
            return [self _playHintModel];
            break;
            
        case ZZHintsTypeViewedHint:
            return [self _viewedHint];
            break;
            
        case ZZHintsTypeInviteSomeElseHint:
            return [self _inviteSomeoneElseHint];
            break;
            
        case ZZHintsTypeRecrodWelcomeHint:
            return [self _recordWelocmeHint];
            break;
            
        case ZZHintsTypeSendWelcomeHintForFriendWithoutApp:
            return [self _welcomeHintForUserWithoutApp];
            break;
            
        case ZZHintsTypeRecordAndTapToPlay:
            return [self _recordAndTapToPlay];
            break;
            
        default:
            break;
    }

    return nil;
}

#pragma mark - Private

+ (NSArray *)_possiblePhrases
{
    return @[
            @"Unlock a secret feature \n Just Zazo someone else!",
            @"A gift is waiting \n Just Zazo someone else!",
            @"Unlock a surprise \n Just Zazo someone else!",
            @"Surprise feature waiting \n Just Zazo someone else!",
    ];
}

#pragma mark - Lazy Load

+ (ZZHintsDomainModel *)_recordAndTapToPlay
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hint.record.and.tap.to.play", nil);
    model.type = ZZHintsTypeRecordAndTapToPlay;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_welcomeHintForUserWithoutApp
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.welcome-nudge-user.label.text", nil);
    model.type = ZZHintsTypeSendWelcomeHintForFriendWithoutApp;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}


+ (ZZHintsDomainModel *)_recordWelocmeHint
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.press-to-record.label.text", nil);
    model.type = ZZHintsTypeRecrodWelcomeHint;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}


+ (ZZHintsDomainModel *)_inviteSomeoneElseHint
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = [self _possiblePhrases].zz_randomObject;
    model.type = ZZHintsTypeInviteSomeElseHint;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_viewedHint
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.viewed-video.label.text", nil);
    model.type = ZZHintsTypeViewedHint;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeGotIt;

    return model;
}

+ (ZZHintsDomainModel *)_playHintModel
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.play-video.label.text", nil);
    model.type = ZZHintsTypePlayHint;
    model.hidesArrow = NO;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_fullscreenHintModel
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];

    model.title = NSLocalizedString(@"hints.fullscreen.label.text", nil);
    model.type = ZZHintsTypeFullscreenUsageHint;
    model.hidesArrow = YES;

    return model;
}

+ (ZZHintsDomainModel *)_playbackControlsHintModel
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    
    model.title = NSLocalizedString(@"hints.fullscreen.label.text", nil);
    model.type = ZZHintsTypePlaybackControlsUsageHint;
    model.hidesArrow = YES;

    return model;
}

+ (ZZHintsDomainModel *)_sendZazoModel
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.send-a-zazo.label.text", @"");
    model.angle = 0.f;
    model.type = ZZHintsTypeInviteHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_pressAndHoldToRecord
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.press-to-record.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeRecordHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_zazoSent
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.send-first-video.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeSentHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeGotIt;

    return model;
}

+ (ZZHintsDomainModel *)_giftIsWaiting
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = [self _possiblePhrases].zz_randomObject;
    model.angle = -95.f;
    model.type = ZZHintsTypeGiftIsWaiting;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypePresent;

    return model;
}

+ (ZZHintsDomainModel *)_tapToSwitchCamera
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.switch-camera.label.text", @"");
    model.angle = 30;
    model.type = ZZHintsTypeFrontCameraUsageHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_welcomeNudgeUser
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.welcome-nudge-user.label.text", @"");
    model.angle = 30;
    model.type = ZZHintsTypeWelcomeNudgeUser;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_welcomeFor
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.welcome-for.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeSendWelcomeHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;

    return model;
}

+ (ZZHintsDomainModel *)_abortRecording
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.abort-recording.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeAbortRecordingUsageHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeTryItNow;

    return model;
}

+ (ZZHintsDomainModel *)_editFriends
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.delete-a-friend.label.text", @"");
    model.angle = -95.f;
    model.type = ZZHintsTypeDeleteFriendUsageHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeGotIt;

    return model;
}

+ (ZZHintsDomainModel *)_earpieceUsage
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.earpiece-usage.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeEarpieceUsageHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeTryItNow;

    return model;
}

+ (ZZHintsDomainModel *)_spin
{
    ZZHintsDomainModel *model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.spin-usage.label.text", @"");
    model.angle = 90.f;
    model.type = ZZHintsTypeSpinUsageHint;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeTryItNow;

    return model;
}

@end