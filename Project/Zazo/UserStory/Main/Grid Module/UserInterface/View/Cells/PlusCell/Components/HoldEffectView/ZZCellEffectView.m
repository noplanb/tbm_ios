//
//  ZZCellEffectView.m
//  Zazo
//
//  Created by Rinat on 29/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZCellEffectView.h"
#import "ZZHoldEffectLayer.h"

@interface ZZCellEffectView ()

@property (nonatomic, readonly) ZZHoldEffectLayer *effectLayer;

@end

@implementation ZZCellEffectView

@dynamic effectLayer;

- (ZZHoldEffectLayer *)effectLayer
{
    return (id)self.layer;
}

+ (Class)layerClass
{
    return [ZZHoldEffectLayer class];
}

- (void)showEffect:(ZZCellEffectType)animationType
{
    [self.superview bringSubviewToFront:self];
    [self.effectLayer animate:animationType];
}

@end
