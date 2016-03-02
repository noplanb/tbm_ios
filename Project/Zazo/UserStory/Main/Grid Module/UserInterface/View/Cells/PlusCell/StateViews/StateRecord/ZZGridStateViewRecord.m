//
//  ZZGridCollectionCellRecordView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewRecord.h"
#import "ZZGridUIConstants.h"
#import "ZZRecordButtonView.h"

@interface ZZGridStateViewRecord ()


@end

@implementation ZZGridStateViewRecord

- (instancetype)initWithPresentedView:(UIView *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self backgroundView];
        [self userNameLabel];
        [self recordView];
//        [self containFriendView];
//        [self uploadingIndicator];
        [self uploadBarView];
//        [self downloadIndicator];
        [self downloadBarView];
        [self badge];
        [self videoViewedView];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    [super updateWithModel:model];
}

#pragma mark - Private

- (ZZRecordButtonView *)recordView
{
    if (!_recordView)
    {
        _recordView = [ZZRecordButtonView new];
        _recordView.userInteractionEnabled = YES;
        [self addSubview:_recordView];
        _recordView.tintColor = self.backgroundView.tintColor;
        
        UITapGestureRecognizer *recognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(animate)];

        [_recordView addGestureRecognizer:recognizer];
        
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self.userNameLabel.mas_top).with.offset(-kSidePadding);
//            make.left.top.equalTo(self).offset(kSidePadding);
//            make.right.equalTo(self).offset(-kSidePadding);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            
        }];
    }
    return _recordView;
}

- (void)animate
{
    [self.recordView animate];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)showAppearAnimation
{
    CAShapeLayer *oval = [CAShapeLayer layer];
    oval.delegate = self;
    oval.backgroundColor = [UIColor clearColor].CGColor;
    
    CGFloat diameter = self.frame.size.width + self.frame.size.height;
    
    CGRect rect = CGRectMake((self.frame.size.width - diameter) /2,
                             (self.frame.size.height - diameter) /2,
                             diameter,
                             diameter);
    
    oval.path = CGPathCreateWithEllipseInRect(rect, nil);
    oval.fillColor = [UIColor blackColor].CGColor;
    oval.frame = self.bounds;

    self.layer.mask = oval;
    
    oval.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    oval.transform = CATransform3DIdentity;
}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if ([event isEqualToString:@"transform"])
    {
        if (CATransform3DEqualToTransform(self.layer.mask.transform, CATransform3DIdentity))
        {
            return nil;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = [NSValue valueWithCATransform3D:self.layer.mask.transform];
        animation.duration = 1;
        return animation;
    }
    
    return nil;
}

@end
