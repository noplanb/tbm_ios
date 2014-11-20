//
//  TBMHomeViewController+Bench.h
//  tbm
//
//  Created by Sani Elfishawy on 11/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"

@interface TBMHomeViewController (Bench) <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
- (void)addBenchGestureRecognizers;
@end
