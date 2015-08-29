//
//  TBMContentViewModal.m
//  tbm
//
//  Created by Sani Elfishawy on 11/19/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMContentViewModal.h"
#import <QuartzCore/QuartzCore.h>

@interface TBMContentViewModal()
@property (nonatomic) NSString *title;
@property (nonatomic) UIView *parentView;
@property (nonatomic) NSString *cancelTxt;
@property (nonatomic) NSString *enterTxt;
@property (nonatomic) UIView *childView;

@property (nonatomic) int modalTag;
@property (nonatomic) float titleHeight;
@property (nonatomic) float buttonHeight;
@property (nonatomic) float maxWidth;

@property (nonatomic, copy) void (^enter)();
@property (nonatomic, copy) void (^cancel)();
@end

@implementation TBMContentViewModal

- (instancetype) initWithParentView:(UIView *)parentView
                              title:(NSString *)title
                          cancelTxt:(NSString *)cancel
                           enterTxt:(NSString *)enter
                          childView:(UIView *)childView
                           didEnter:(void (^)())didEnter
                          didCancel:(void (^)())didCancel{
    self = [super init];
    if (self !=nil){
        _parentView = parentView;
        _title = title;
        _cancelTxt = cancel;
        _enterTxt = enter;
        _childView = childView;
        
        _modalTag = 848738;
        _titleHeight = 60;
        _buttonHeight = 60;
        _maxWidth = 400;
        
        _cancel = didCancel;
        _enter = didEnter;
    }
    return self;
}

//--------------
// Show and hide
//--------------
- (void) show{
    [self.parentView addSubview:[self dimParent]];
    [self.parentView addSubview:[self modal]];
}

- (void) hide{
    for (UIView *v in [self.parentView subviews]){
        if (v.tag == self.modalTag)
            [v removeFromSuperview];
    }
}

//----------
// The Views
//----------
- (UIView *) dimParent{
    UIView *dp = [[UIView alloc] initWithFrame:self.parentView.frame];
    [dp setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
    dp.tag = self.modalTag;
    return dp;
}

- (UIView *) modal{
    CGRect f = CGRectMake([self modalOriginX], [self modalOriginY], [self modalWidth], [self modalHeight]);
    UIView *modal = [[UIView alloc] initWithFrame:f];
    modal.tag = self.modalTag;
    [modal addSubview:[self titleLabel]];
    [modal addSubview:[self contentView]];
    [modal.layer addSublayer:[self topLine]];
    [modal.layer addSublayer:[self bottomLine]];
    [modal.layer addSublayer:[self verticalLine]];
    [modal addSubview:[self cancelButton]];
    [modal addSubview:[self enterButton]];
    modal.layer.masksToBounds = YES;
    modal.layer.cornerRadius = 5;
    modal.backgroundColor = [UIColor colorWithWhite:255 alpha:1];
    return modal;
}

- (UILabel *)titleLabel{
    CGRect f = CGRectMake(0, 0, [self modalWidth], self.titleHeight);
    UILabel *title = [[UILabel alloc] initWithFrame:f];
    [title setText: self.title];
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;
    [title setClipsToBounds:YES];
    return title;
}

- (UIView *)contentView{
    UIView *cv = self.childView;
    CGRect r = cv.frame;
    r.size.width = [self modalWidth];
    r.origin.x = 0;
    r.origin.y = self.titleHeight;
    cv.frame = r;
    return cv;
}

- (CALayer *)topLine{
    CALayer *tl = [self line];
    tl.frame = CGRectMake(0, self.titleHeight, [self modalWidth], 1);
    return tl;
}

- (CALayer *)bottomLine{
    CALayer *bl = [self line];
    CGRect contentFrame = [self contentView].frame;
    bl.frame = CGRectMake(0, contentFrame.origin.y + contentFrame.size.height, [self modalWidth], 1);
    return bl;
}

- (CALayer *)verticalLine{
    CALayer *l = [self line];
    CGRect contentFrame = [self contentView].frame;
    l.frame = CGRectMake([self modalWidth]/2, contentFrame.origin.y + contentFrame.size.height, 1, self.buttonHeight);
    return l;
}

- (CALayer *)line{
    CALayer *l = [CALayer layer];
    l.backgroundColor = [UIColor lightGrayColor].CGColor;
    return l;
}

- (UIButton *)button{
    CGRect contentFrame = [self contentView].frame;
    CGRect f = CGRectMake(0, contentFrame.origin.y + contentFrame.size.height, [self modalWidth]/2, self.buttonHeight);
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = f;
    b.titleLabel.font = [UIFont systemFontOfSize:18];
    return b;
}

- (UIButton *)cancelButton{
    UIButton *b = [self button];
    [b setTitle:self.cancelTxt forState:UIControlStateNormal];
    [b addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)cancelClick{
    [self hide];
    _cancel();
}

- (UIButton *)enterButton{
    UIButton *b = [self button];
    CGRect f = b.frame;
    f.origin.x = [self modalWidth] / 2;
    b.frame = f;
    [b setTitle:self.enterTxt forState:UIControlStateNormal];
    [b addTarget:self action:@selector(enterClick) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)enterClick{
    [self hide];
    _enter();
}


//-----------------------
// Dimension calculations
//-----------------------
- (float) modalWidth{
    return fminf(0.85 * [self screenWidth], self.maxWidth);
}

- (float) modalOriginX{
    return ([self screenWidth] - [self modalWidth]) / 2;
}

- (float) modalOriginY{
    return ([self screenHeight] - [self modalHeight]) / 2;
}

- (float) modalHeight{
    return self.titleHeight + [self contentHeight] + self.buttonHeight;
}

- (float)screenWidth{
    return [[UIScreen mainScreen] bounds].size.width;
}

- (float)screenHeight{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float)maxModalHeight{
    return 0.75 * [self screenHeight];
}

- (float)contentHeight{
    return self.childView.frame.size.height;
}

@end
