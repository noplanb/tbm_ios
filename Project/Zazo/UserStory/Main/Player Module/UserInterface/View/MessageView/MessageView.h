//
//  MessageView.h
//  Zazo
//
//  Created by Rinat on 16/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;


@end
