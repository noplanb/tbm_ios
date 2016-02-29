//
//  ZZCircleView.h
//  Zazo
//
//  Created by Rinat on 25/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ZZCircleView : UIView

@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UIImageView *imageView;

- (void)animate;

@end
