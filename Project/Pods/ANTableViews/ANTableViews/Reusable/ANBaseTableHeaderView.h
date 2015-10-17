//
//  ANBaseTableHeaderFooterView.h
//
//  Created by Oksana Kovalchuk on 4/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableViewHeaderFooterView.h"

@interface ANBaseTableHeaderView : ANTableViewHeaderFooterView

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, assign) CGFloat leftLabelInset;
@property (nonatomic, assign) CGFloat bottomLabelInset;

@end
