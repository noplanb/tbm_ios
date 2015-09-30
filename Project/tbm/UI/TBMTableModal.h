//
//  TBMTableModal.h
//  SDCAlertViewControllerWithTableView
//
//  Created by Sani Elfishawy on 11/17/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;

@protocol TBMTableModalDelegate <NSObject>

- (void)updatePrimaryPhoneNumberForContact:(ZZContactDomainModel*)contact;


@end

@interface TBMTableModal : NSObject <UITableViewDelegate, UITableViewDataSource>

- (void)initWithParentView:(UIView *)parentView
                     title:(NSString *)title
                   contact:(ZZContactDomainModel*)contact
                  delegate:(id<TBMTableModalDelegate>)delegate;
- (void) show;
- (void) hide;

+ (instancetype)shared;

@end
