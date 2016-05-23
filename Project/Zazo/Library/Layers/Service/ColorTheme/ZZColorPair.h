//
//  ZZColorPair.h
//  Zazo
//
//  Created by Rinat on 23/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZColorPair : NSObject

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *backgroundColor;

+ (instancetype)randomPair;
+ (instancetype)colorForUsername:(NSString *)username;

@end