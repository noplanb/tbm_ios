//
// Created by Rinat on 01/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZAddContactButton.h"

@interface ZZAddContactButton ()

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

@end

@implementation ZZAddContactButton

@synthesize imageView = _imageView, textLabel = _textLabel;

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
        
        self.isActive = NO;
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
        make.center.equalTo(self).centerOffset(CGPointMake(0, -16));
        make.width.equalTo(self.mas_width).multipliedBy(3.0f/4.0f).priorityHigh();
        make.width.lessThanOrEqualTo(@85);
        make.height.equalTo(self.mas_width);
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

#pragma mark Setters & getters

- (UILabel *)textLabel
{
    if (_textLabel) {
        return _textLabel;
    }
    
    _textLabel = [UILabel new];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [UIFont zz_boldFontWithSize:16];
    _textLabel.text = @"Add contact";
    _textLabel.textColor = [UIColor grayColor];
    _textLabel.minimumScaleFactor = 0.25;
    _textLabel.adjustsFontSizeToFitWidth = YES;
    [_textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self addSubview:_textLabel];
    
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-16);
    }];
    
    
    return _textLabel;
}

- (void)setIsActive:(BOOL)isActive {
    _isActive = isActive;

    NSString *imageName = isActive ? @"contact-button-pink" : @"contact-button-gray";
    UIImage *image = [UIImage imageNamed:imageName];

    self.imageView.image = image;

    self.textLabel.hidden = !isActive;
}

- (void)setPlusViewHidden:(BOOL)hidden animated:(BOOL)animated completion:(ANCodeBlock)completion
{
    ANCodeBlock changes = ^{
        self.imageView.transform =
        hidden ?
        CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f) :
        CGAffineTransformIdentity;
        
        self.imageView.alpha = hidden ? 0 : 1;
        self.textLabel.alpha = hidden ? 0 : 1;
    };
    
    if (!animated)
    {
        changes();
        if (completion)
        {
            completion();
        }
        return;
    }
    
    [UIView animateWithDuration:0.5f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:0
                     animations:changes
                     completion:^(BOOL finished) {
                         if (completion)
                         {
                             completion();
                         }
                     }];

}

@end