//
//  ZZHintsController.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"

@class ZZHintsDomainModel;

@protocol ZZHintsControllerDelegate <NSObject>

- (void)hintWasDissmissed;

@end

@interface ZZHintsController : NSObject

@property (nonatomic, weak) id<ZZHintsControllerDelegate> delegate;

- (void)showHintWithModel:(ZZHintsDomainModel*)model;

@end
