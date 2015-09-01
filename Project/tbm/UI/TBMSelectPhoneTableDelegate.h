//
//  TBMSelectPhoneTableDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 11/14/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

// I have to use this separate class as a delegate for the selectPhoneTable in HomeViewController+invite becuase
// HomeViewController+bench also has a table for which it is a delegate and the delegate callbacks interfere.
// Categories are pure shit.


@protocol TBMSelectPhoneTableCallback <NSObject>
- (void) didClickOnPhoneObject:(NSDictionary *)phoneObject;
@end

@interface TBMSelectPhoneTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>
- initWithContact:(NSDictionary *)contact delegate:(id<TBMSelectPhoneTableCallback>)delegate;
@end
