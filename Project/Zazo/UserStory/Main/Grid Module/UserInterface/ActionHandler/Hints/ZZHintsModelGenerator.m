//
//  ZZHintsModelGenerator.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsModelGenerator.h"
#import "ZZHintsDomainModel.h"
#import "NSArray+TBMArrayHelpers.h"

@implementation ZZHintsModelGenerator

+ (ZZHintsDomainModel*)generateHintModelForType:(ZZHintsType)hintType
{
    switch (hintType)
    {
        case ZZHintsTypeSendZazo:
            return [self _sendZazoModel];
        break;
            
        case ZZHintsTypePressAndHoldToRecord:
            return [self _pressAndHoldToRecord];
        break;
            
        case ZZHintsTypeZazoSent:
            return [self _zazoSent];
        break;
            
        case ZZHintsTypeGiftIsWaiting:
            return [self _giftIsWaiting];
        break;
            
        case ZZHintsTypeTapToSwitchCamera:
            return [self _tapToSwitchCamera];
        break;
            
        case ZZHintsTypeWelcomeNudgeUser:
            return [self _welcomeNudgeUser];
        break;
            
        case ZZHintsTypeWelcomeFor:
            return [self _welcomeFor];
        break;
            
        case ZZHintsTypeAbortRecording:
            return [self _abortRecording];
        break;
            
        case ZZHintsTypeEditFriends:
            return [self _editFriends];
        break;
        
        case ZZHintsTypeEarpieceUsage:
            return [self _earpieceUsage];
        break;
        
        case ZZHintsTypeSpin:
            return [self _spin];
        break;
            
            
        default: break;
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

+ (ZZHintsDomainModel*)_sendZazoModel
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.send-a-zazo.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeSendZazo;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;
    
    return model;
}

+ (ZZHintsDomainModel*)_pressAndHoldToRecord
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.press-to-record.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypePressAndHoldToRecord;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;
    
    return model;
}

+ (ZZHintsDomainModel*)_zazoSent
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.send-first-video.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeZazoSent;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeGotIt;
    
    return model;
}

+ (ZZHintsDomainModel*)_giftIsWaiting
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = [self _possiblePhrases].randomObject;
    model.angle = -95.f;
    model.type = ZZHintsTypeGiftIsWaiting;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypePresent;
    
    return model;
}

+ (ZZHintsDomainModel*)_tapToSwitchCamera
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.switch-camera.label.text", @"");
    model.angle = 30;
    model.type = ZZHintsTypeTapToSwitchCamera;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeNone;
    
    return model;
}

+ (ZZHintsDomainModel*)_welcomeNudgeUser
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.welcome-nudge-user.label.text", @"");
    model.angle = 30;
    model.type = ZZHintsTypeWelcomeNudgeUser;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeNone;
    
    return model;
}

+ (ZZHintsDomainModel*)_welcomeFor
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.welcome-for.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeWelcomeFor;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeNone;
    
    return model;
}

+ (ZZHintsDomainModel*)_abortRecording
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.abort-recording.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeAbortRecording;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeTryItNow;
    
    return model;
}

+ (ZZHintsDomainModel*)_editFriends
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.delete-a-friend.label.text", @"");
    model.angle = -95.f;
    model.type = ZZHintsTypeEditFriends;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeGotIt;
    
    return model;
}

+ (ZZHintsDomainModel*)_earpieceUsage
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.earpiece-usage.label.text", @"");
    model.angle = -90.f;
    model.type = ZZHintsTypeEarpieceUsage;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypeTryItNow;
    
    return model;
}

+ (ZZHintsDomainModel*)_spin
{
    ZZHintsDomainModel* model = [ZZHintsDomainModel new];
    model.title = NSLocalizedString(@"hints.spin-usage.label.text", @"");
    model.angle = 90.f;
    model.type = ZZHintsTypeSpin;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionLeft;
    model.imageType = ZZHintsBottomImageTypeTryItNow;
    
    return model;
}

@end
