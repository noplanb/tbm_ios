//
//  TBMTableModal.h
//  SDCAlertViewControllerWithTableView
//
//  Created by Sani Elfishawy on 11/17/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TBMTableModalDelegate <NSObject>
- (void) didSelectRow:(NSInteger)index;
@end

@interface TBMTableModal : NSObject <UITableViewDelegate, UITableViewDataSource>
- (instancetype) initWithParentView:(UIView *)parentView
                              title:(NSString *)title
                            rowData:(NSArray*)rowData
                           delegate:(id<TBMTableModalDelegate>)delegate;
- (void) show;
- (void) hide;
@end
