//
//  ZZHintsModelGenerator.m
//  Zazo
//
//  Created by Oleg Panforov on 9/22/15.
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
    model.type = ZZHintsTypeZazoSent;
    model.hidesArrow = NO;
    model.arrowDirection = ZZArrowDirectionRight;
    model.imageType = ZZHintsBottomImageTypePresent;
    
    return model;
}

@end
