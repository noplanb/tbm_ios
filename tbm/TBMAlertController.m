//
//  TBMAlertController.m
//  tbm
//
//  Created by Matt Wayment on 1/8/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"
#import "TBMAlertControllerView.h"
#import "SDCIntrinsicallySizedView.h"
#import "TBMAlertControllerVisualStyle.h"

@implementation TBMAlertController

@dynamic alert;

#pragma mark - Initialization

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
    // Alert title text
    NSMutableAttributedString *alertTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [alertTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, alertTitle.length)];
    
    // Alert body text
    NSMutableAttributedString *alertMsg = [[NSMutableAttributedString alloc] initWithString:message];
    [alertMsg addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:0.16f green:0.15f blue:0.13f alpha:1.0f]
                     range:NSMakeRange(0, alertMsg.length)];
    
    NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
    style.alignment = NSTextAlignmentCenter;
    [style setLineSpacing:6];
    [alertMsg addAttribute:NSParagraphStyleAttributeName
                     value:style
                     range:NSMakeRange(0, alertMsg.length)];
    
    TBMAlertController *alert = [super alertControllerWithAttributedTitle:alertTitle
                                                        attributedMessage:alertMsg
                                                           preferredStyle:SDCAlertControllerStyleAlert];
    
    // Set our custom visual style for the alerts
    alert.visualStyle = [[TBMAlertControllerVisualStyle alloc] init];
    
    if (alert.legacyAlertView) {
        // iOS 7 style alerts
        SDCAlertController *alert = [super alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
        return alert;
    }

    return alert;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Main background color of alert
    self.alert.backgroundColor = [UIColor colorWithRed:0.95f green:0.94f blue:0.91f alpha:1.0f];
    
    // Title bar background
    UIView *topBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    topBG.backgroundColor = [UIColor colorWithRed:0.96f green:0.55f blue:0.19f alpha:1.0f];
    [self.alert addSubview:topBG];
    [self.alert sendSubviewToBack:topBG];
    
    // Translucent overlay that covers entire screen (sits behind alert)
    self.view.backgroundColor = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:0.8f];
}

#pragma mark - Alert View

- (void)createAlert {
    // Instantiate custom alert controller view
    NSAttributedString *title = self.attributedTitle ? : [self attributedStringForString:self.title];
    NSAttributedString *message = self.attributedMessage ? : [self attributedStringForString:self.message];
    self.alert = [[TBMAlertControllerView alloc] initWithTitle:title message:message];
    
    self.alert.delegate = self;
    self.alert.contentView = [[SDCIntrinsicallySizedView alloc] init];
    [self.alert.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (NSAttributedString *)attributedStringForString:(NSString *)string {
    return string ? [[NSAttributedString alloc] initWithString:string] : nil;
}

#pragma mark - Alert Actions

- (void)alertControllerView:(SDCAlertControllerView *)sender didPerformAction:(SDCAlertAction *)action {
    if (!action.isEnabled || (self.shouldDismissBlock && !self.shouldDismissBlock(action))) {
        return;
    }
    
    [self dismissWithCompletion:^{
        if (action.handler) {
            action.handler(action);
        }
    }];
}

@end
