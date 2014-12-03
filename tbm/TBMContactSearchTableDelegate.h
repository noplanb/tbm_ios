//
//  TBMContactSearchTableDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 11/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBMContactSearchTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *dataArray;
@property (nonatomic) NSString *cellBackgroundColor;
@property (nonatomic) NSString *cellTextColor;

- (instancetype)initWithSelectCallback:(void (^)(NSString *))selectCallback;
@end
