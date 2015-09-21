//
//  ZZHintsView.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import QuartzCore;
#import "ZZHintsView.h"
#import "TBMHintArrow.h"
#import "ZZArrowDirectionHelper.h"

@interface ZZHintsView ()

@property (nonatomic, strong) ZZArrowDirectionHelper* arrowDirectonHelper;

@end

@implementation ZZHintsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialViewDidTap:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

- (void)updateWithType:(ZZHintsType)type andFocusOnView:(UIView*)view
{
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.frame];
    
    CGRect highlightFrame = view.frame;
    
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:highlightFrame];
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.65].CGColor;
    
    [self.layer addSublayer:fillLayer];
    
    TBMHintArrow *hintView;
    
    switch (type) {
        case ZZHintsTypeSendZazo:
        {
            hintView = [TBMHintArrow arrowWithText:@"Send a Zazo"
                                         curveKind:TBMTutorialArrowCurveKindRight
                                        arrowPoint:CGPointMake(CGRectGetMinX(highlightFrame),
                                                               CGRectGetMidY(highlightFrame))
                                             angle:-40.f
                                            hidden:NO
                                             frame:self.frame];

        } break;
        case ZZHintsTypePressAndHoldToRecord:
        {
            

        } break;
        case ZZHintsTypeZazoSent:
        {
            

        } break;
        case ZZHintsTypeGiftIsWaiting:
        {
            
            
        } break;
            
        default: break;
    }
    

    [self addSubview:hintView];
}

- (void)tutorialViewDidTap:(UITapGestureRecognizer *)sender
{
    [self dismissHintsView];
}

- (void)dismissHintsView
{
    [self removeFromSuperview];
}

@end
