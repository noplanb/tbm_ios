//
//  TBMBenchTableViewCell.m
//  tbm
//
//  Created by Matt Wayment on 1/14/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMBenchTableViewCell.h"

float const BENCH_CELL_THUMB_IMAGE_RIGHT_MARGIN = 10.0;

@implementation TBMBenchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 10.0, 36.0, 36.0f)];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        
        float nameX = _thumbImageView.frame.origin.x + _thumbImageView.frame.size.width + BENCH_CELL_THUMB_IMAGE_RIGHT_MARGIN;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, 10.0, 100.0f, 36.0)];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0];

        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_thumbImageView];
        
        UIView *botBorderTopView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 54.0f, self.frame.size.width, 1.0f)];
        botBorderTopView.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:1.0f];
        botBorderTopView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView *botBorderBotView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 55.0f, self.frame.size.width, 1.0f)];
        botBorderBotView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.33 alpha:1.0f];
        botBorderBotView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.contentView.autoresizesSubviews = YES;
        [self.contentView addSubview:botBorderTopView];
        [self.contentView addSubview:botBorderBotView];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
