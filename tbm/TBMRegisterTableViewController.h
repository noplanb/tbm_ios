//
//  TBMRegisterTableViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBMRegisterProtocol <NSObject>
- (void) didSelectUser;
@end

@interface TBMRegisterTableViewController : UITableViewController
@property NSMutableArray *users;
@property (nonatomic) id <TBMRegisterProtocol> delegate;
@end
