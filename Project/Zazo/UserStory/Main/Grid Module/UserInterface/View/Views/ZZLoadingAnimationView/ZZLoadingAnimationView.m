//
//  ZZDownloadAnimationView.m
//  Animation
//
//  Created by Rinat on 26/02/16.
//  Copyright © 2016 No plan B. All rights reserved.
//

#import "ZZLoadingAnimationView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Masonry.h>

static NSMutableDictionary <NSNumber *, NSArray <UIImage *> *> *AnimationsFramesCache; // to avoid frames loading each time
static CGFloat ZZAnimationDuration = 2.0f;

@interface ZZLoadingAnimationView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) ANCodeBlock completion;

@end

@implementation ZZLoadingAnimationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupView];
}

- (void)animateWithType:(ZZLoadingAnimationType)type completion:(ANCodeBlock)completion
{
    if (self.completion) // this means animation in progress
    {
        ANCodeBlock currentCompletion = [self.completion copy];
        
        self.completion = ^{
            currentCompletion();
            completion();
        };
        
        return;
    }
    
    self.completion = [completion copy];
    
    [self.superview bringSubviewToFront:self];
    
    self.imageView.animationImages = [self _framesForAnimationType:type];
    [self animate];
}

- (NSArray <UIImage *> *)_framesForAnimationType:(ZZLoadingAnimationType)type
{
    [self _loadFramesToCacheIfNeededForAnimationType:type];
    return AnimationsFramesCache[@(type)];
}

- (NSArray <UIImage *> *)_framesWithFileTemplate:(NSString *)template frameCount:(NSUInteger)count
{
    NSMutableArray <UIImage *> *images = [NSMutableArray new];
    
    for (NSUInteger index = 0; index < count; index++)
    {
        NSString *fileName = [NSString stringWithFormat:template, (unsigned long)index];
        UIImage *image = [UIImage imageNamed:fileName];
        [images addObject:image];
    }
    
    return [images copy];
}

- (void)_loadFramesToCacheIfNeededForAnimationType:(ZZLoadingAnimationType)type
{
    if (AnimationsFramesCache[@(type)])
    {
        return;
    }
    
    AnimationsFramesCache[@(type)] = [self _loadFramesForAnimationType:type];
}

- (NSArray <UIImage *> *)_loadFramesForAnimationType:(ZZLoadingAnimationType)type
{
    switch (type) {
        case ZZLoadingAnimationTypeUploading:
            return [self _framesWithFileTemplate:@"send_%02lu" frameCount:51];
            break;
        case ZZLoadingAnimationTypeDownloading:
            return [self _framesWithFileTemplate:@"download_%02lu" frameCount:51];
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)_setupView
{
    if (!AnimationsFramesCache)
    {
        AnimationsFramesCache = [NSMutableDictionary new];
    }
    
    UIImageView *imageView = [UIImageView new];
    imageView.animationDuration = ZZAnimationDuration;
    imageView.animationRepeatCount = 1;
    [self addSubview:imageView];
    
    self.imageView = imageView;
}

- (void)animate
{
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.imageView startAnimating];
    [self.imageView sizeToFit];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.16 green:0.4 blue:0.77 alpha:0.75];
    }];
    
    [self performSelector:@selector(moveToCorner) withObject:nil afterDelay:1.8f];
}

- (void)moveToCorner
{
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0).offset(-32);
        make.right.equalTo(@0).offset(32);
    }];
    
    [UIView animateWithDuration:0.4f
                          delay:0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.5f
                        options:0
                     animations:^{
                         [self layoutIfNeeded];
                         self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        
        [self.superview sendSubviewToBack:self];
        
        if (self.completion)
        {
            self.completion();
            self.completion = nil;
        }
    }];
}

@end
