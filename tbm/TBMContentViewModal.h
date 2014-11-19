//
//  TBMContentViewModal.h
//  tbm
//
//  Created by Sani Elfishawy on 11/19/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBMContentViewModal : NSObject
- (instancetype) initWithParentView:(UIView *)parentView
                              title:(NSString *)title
                          cancelTxt:(NSString *)cancel
                           enterTxt:(NSString *)enter
                          childView:(UIView *)childView
                           didEnter:(void (^)())didEnter
                          didCancel:(void (^)())didCancel;
- (void) show;
- (void) hide;

@end
