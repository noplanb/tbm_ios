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

@interface TBMAlertController ()

@property (nonatomic, assign) BOOL dismissWithApplication;

@end


@implementation TBMAlertController

@dynamic alert;

#pragma mark - Initialization

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    return [self alertControllerWithTitle:title message:message forcePlain:NO];
}

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message forcePlain:(BOOL)forcePlain
{
    
    TBMAlertController *alert = [super alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
                                 
    
    if (alert.legacyAlertView || forcePlain)
    {
        // iOS 7 style alerts
        SDCAlertController *alert = [self alertControllerWithTitle:title
                                                            message:message
                                                     preferredStyle:SDCAlertControllerStyleAlert];
        return alert;
    }
    
    return alert;
}

+ (NSAttributedString *)_attributedStringForTitle:(NSString *)title
{
    NSMutableAttributedString *alertTitle =
    [[NSMutableAttributedString alloc] initWithString:title];
    
    [alertTitle addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:NSMakeRange(0, alertTitle.length)];
    
    return [alertTitle copy];
}

+ (NSAttributedString *)_attributedStringForMessage:(NSString *)message
{
//    if (ANIsEmpty(message))
//    {
//        return [self _zeroSizeAttributedString];
//    }
    
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

    return [alertMsg copy];
}

+ (NSAttributedString *)_zeroSizeAttributedString
{
    NSAttributedString *emptyMessage =
    [[NSAttributedString alloc] initWithString:@"" attributes:@{
                                                                NSFontAttributeName: [UIFont systemFontOfSize:0.1],
                                                                NSForegroundColorAttributeName: [UIColor clearColor]
                                                                }];
    return emptyMessage;
}

+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)attributedTitle
                                 attributedMessage:(NSAttributedString *)attributedMessage
                                    preferredStyle:(SDCAlertControllerStyle)preferredStyle
{
    TBMAlertController *alertController = [super alertControllerWithAttributedTitle:attributedTitle
                                                        attributedMessage:attributedMessage
                                                           preferredStyle:preferredStyle];
    
    // Set our custom visual style for the alerts
    
    return alertController;
    
}

+ (id)badConnectionAlert
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString* badConnectionMessage = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];
    NSString* title = @"Bad Connection";
    
    return [self alertControllerWithTitle:title message:badConnectionMessage forcePlain:NO];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Main background color of alert
    
    // Title bar background
    
    // Translucent overlay that covers entire screen (sits behind alert)
}

#pragma mark - Alert View

- (void)createAlert
{
    // Instantiate custom alert controller view
    NSAttributedString *title = self.attributedTitle ? : [self attributedStringForString:self.title];
    NSAttributedString *message = self.attributedMessage ? : [self attributedStringForString:self.message];
    self.alert = [[TBMAlertControllerView alloc] initWithTitle:title message:message];
    
    self.alert.delegate = self;
    self.alert.contentView = [[SDCIntrinsicallySizedView alloc] init];
    [self.alert.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (NSAttributedString *)attributedStringForString:(NSString *)string
{
    return string ? [[NSAttributedString alloc] initWithString:string] : nil;
}

#pragma mark - Alert Actions

- (void)alertControllerView:(SDCAlertControllerView *)sender didPerformAction:(SDCAlertAction *)action
{
    if (!action.isEnabled || (self.shouldDismissBlock && !self.shouldDismissBlock(action))) {
        return;
    }
    
    [self dismissWithCompletion:^{
        if (action.handler) {
            action.handler(action);
        }
    }];
}

#pragma mark dismissWithApplication

- (void)dismissWithApplicationAutomatically
{
    if (self.dismissWithApplication)
    {
        return;
    }
    
    self.dismissWithApplication = YES;
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(_appWillDisappearNotification)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
    
}

- (void)_appWillDisappearNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    self.dismissWithApplication = NO;
    [self dismissWithCompletion:nil];
}

@end
