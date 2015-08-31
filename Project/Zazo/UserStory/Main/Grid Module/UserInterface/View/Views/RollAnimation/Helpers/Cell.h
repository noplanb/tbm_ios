//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cell : UIView
@property(nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) NSIndexPath* indexPath;
@property (nonatomic, strong) UIImageView* stateImageView;
-(void) tapped;
-(void) longTapStarted;
-(void) longTapEnded;

@end