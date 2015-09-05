//
//  ZZGridBaseCell.h
//  Zazo
//
//  Created by ANODA on 13/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AVFoundation;

#import "ANCollectionViewCell.h"

@interface ZZGridBaseCell : ANCollectionViewCell

- (void)showRecordingOverlay;
- (void)hideRecordingOverlay;
- (UIView*)topView;

@end
