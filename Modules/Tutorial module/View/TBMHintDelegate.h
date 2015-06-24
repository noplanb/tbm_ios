//
// Created by Maksim Bazarov on 20/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMHint;

@protocol TBMHintDelegate <NSObject>

-(void)hintDidDismiss:(TBMHint *)hint;
@end