//
//  TBMBenchTableViewCell.m
//  tbm
//
//  Created by Matt Wayment on 1/14/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMBenchTableViewCell.h"

@implementation TBMBenchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0f, 10.0, 100.0f, 36.0)];
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 36.0f, 36.0f)];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;

        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_thumbImageView];
        
        UIView *botBorderTopView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 54.0f, self.frame.size.width, 1.0f)];
        botBorderTopView.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:1.0f];
        
        UIView *botBorderBotView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 55.0f, self.frame.size.width, 1.0f)];
        botBorderBotView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.33 alpha:1.0f];
        
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
