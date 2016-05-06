//
//  ZZDownloadAnimationView.h
//  Animation
//
//  Created by Rinat on 26/02/16.
//  Copyright © 2016 No plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    ZZLoadingAnimationTypeDownloading,
    ZZLoadingAnimationTypeUploading,
} ZZLoadingAnimationType;

extern CGFloat ZZLoadingAnimationDuration;

@interface ZZLoadingAnimationView : UIView

- (void)animateWithType:(ZZLoadingAnimationType)type
                 toView:(UIView *)targetView
             completion:(ANCodeBlock)completion;


- (void)startDownloading;

- (void)finishDownloadingToView:(UIView *)targetView
                     completion:(ANCodeBlock)completion;

@property (nonatomic, assign) CGFloat downloadProgress;

@end
