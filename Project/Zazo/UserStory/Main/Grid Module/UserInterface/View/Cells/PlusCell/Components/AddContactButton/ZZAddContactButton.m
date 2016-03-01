//
// Created by Rinat on 01/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZAddContactButton.h"

@interface ZZAddContactButton ()

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@implementation ZZAddContactButton

@synthesize imageView = _imageView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
        
        self.backgroundColor = [ZZColorTheme shared].gridCellBackgroundColor;
        self.adjustsImageWhenHighlighted = NO;
        self.showsTouchWhenHighlighted = NO;
        self.reversesTitleShadowWhenHighlighted = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);

        [self _makeLayout];
        [self _makeLongTapRecognizer];
    }

    return self;
}

- (void)_makeLongTapRecognizer
{
    UILongPressGestureRecognizer* longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(_itemSelectedWithRecognizer:)];
    
    longPressRecognizer.minimumPressDuration = 0.8;
    [self addGestureRecognizer:longPressRecognizer];

}

- (void)_makeLayout
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    UIView *borderView = [UIView new];
    borderView.userInteractionEnabled = NO;
    borderView.layer.borderWidth = 2;
    borderView.layer.borderColor = [ZZColorTheme shared].gridCellBorderColor.CGColor;

    [self addSubview:borderView];

    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(3, 3, 3, 3));
    }];
}

- (void)_itemSelectedWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark Setters

- (void)setIsActive:(BOOL)isActive {
    _isActive = isActive;

    NSString *imageName = isActive ? @"contact-button-pink" : @"contact-button-gray";
    UIImage *image = [UIImage imageNamed:imageName];

    self.imageView.image = image;

    self.imageEdgeInsets =     // shadow compensation
    isActive ? UIEdgeInsetsMake(-8, -8, -16, -8) : UIEdgeInsetsZero;
}

- (void)setPlusViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    ANCodeBlock changes = ^{
        self.imageView.transform =
        hidden ?
        CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f) :
        CGAffineTransformIdentity;
        
        self.imageView.alpha = hidden ? 0 : 1;
    };
    
    if (!animated)
    {
        changes();
        return;
    }
    
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:0
                     animations:changes
                     completion:nil];

}

@end