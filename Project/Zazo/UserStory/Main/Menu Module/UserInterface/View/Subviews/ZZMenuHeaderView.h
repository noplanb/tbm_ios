//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZMenuHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *imageViewButton;
@property (nonatomic, assign) CGFloat avatarRadius;
@property (nonatomic, strong) UIImageView *patternView;
@property (nonatomic, strong) UILabel *noImageLabel;

@end
