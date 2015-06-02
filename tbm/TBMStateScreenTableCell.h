//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

CGFloat const topLabelHeight = 30.f;
CGFloat const bottomLabelHeight = 15.f;
CGFloat const verticalMargin = 2.f;
CGFloat const leftInset = 15.f;

@interface TBMStateScreenTableCell : UITableViewCell

@property(nonatomic, strong) NSString *mainText;
@property(nonatomic, strong) NSString *additionalText;

@end