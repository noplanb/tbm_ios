//
//  ZZHoldEffectView.m
//  Zazo
//
//  Created by Rinat on 29/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZHoldEffectView.h"
#import "ZZHoldEffectLayer.h"

@interface ZZHoldEffectView ()

@property (nonatomic, readonly) ZZHoldEffectLayer *effectLayer;

@end

@implementation ZZHoldEffectView

@dynamic effectLayer;

- (ZZHoldEffectLayer *)effectLayer
{
    return (id)self.layer;
}

+ (Class)layerClass
{
    return [ZZHoldEffectLayer class];
}

- (void)animate:(ZZGridStateViewLayerAnimationType)animationType
{
    [self.superview bringSubviewToFront:self];
    [self.effectLayer animate:animationType];
}

@end
