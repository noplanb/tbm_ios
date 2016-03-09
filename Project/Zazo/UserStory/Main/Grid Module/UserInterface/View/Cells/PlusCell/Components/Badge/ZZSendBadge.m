//
//  ZZSendBadge.m
//  Zazo
//
//  Created by Rinat on 04/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZSendBadge.h"

@implementation ZZSendBadge

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImageView *planeImage = [UIImageView new];
        planeImage.image = [UIImage imageNamed:@"paper-plane"];
        [self addSubview:planeImage];
        [planeImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        
    }
    return self;
}

@end
