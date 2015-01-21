//
//  TBMBenchTableViewCell.h
//  tbm
//
//  Created by Matt Wayment on 1/14/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float const BENCH_CELL_THUMB_IMAGE_RIGHT_MARGIN;

@interface TBMBenchTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *thumbImageView;

@end
