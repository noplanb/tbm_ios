//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import <UIKit/UIKit.h>

@interface TBMHomeViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *friendViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *friendLabels;
@end

@implementation TBMHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil obbundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView *view in self.friendViews){
        NSInteger tag = view.tag;
        UILabel *label = [self friendLabelWithTag:tag];
        label.text = [NSString stringWithFormat:@"%ld", (long)tag];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIView *)friendViewWithTag:(NSInteger)tag
{
    for (UIView *view in self.friendViews) {
        if (view.tag == tag){
            return view;
        }
    }
    return nil;
}

- (UILabel *)friendLabelWithTag:(NSInteger)tag
{
    NSLog(@"Looking for label with tag = %ld", (long)tag);
    for (UILabel *label in self.friendLabels){
        NSLog(@"found %ld", label.tag);
        if (label.tag == tag){
            return label;
        }
    }
    return nil;
}

@end
