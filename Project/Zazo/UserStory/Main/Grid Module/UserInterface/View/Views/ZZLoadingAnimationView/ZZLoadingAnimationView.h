//
//  ZZDownloadAnimationView.h
//  Animation
//
//  Created by Rinat on 26/02/16.
//  Copyright © 2016 No plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZZLoadingAnimationTypeDownloading,
    ZZLoadingAnimationTypeUploading,
} ZZLoadingAnimationType;

@interface ZZLoadingAnimationView : UIView

- (void)animateWithType:(ZZLoadingAnimationType)type completion:(ANCodeBlock)completion;

@end
