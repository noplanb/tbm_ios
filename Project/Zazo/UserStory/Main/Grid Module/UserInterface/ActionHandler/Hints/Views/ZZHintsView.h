//
//  ZZHintsView.h
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsConstants.h"
@class ZZHintsViewModel;
@protocol ZZGridActionHanlderUserInterfaceDelegate;

@interface ZZHintsView : UIView

@property(nonatomic, weak) id <ZZGridActionHanlderUserInterfaceDelegate> actionHandlerGridDelegate;


- (void)updateWithHintsViewModel:(ZZHintsViewModel*)viewModel;



@end
