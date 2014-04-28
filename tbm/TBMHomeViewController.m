//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import "TBMLongPressTouchHandler.h"
#import "TBMVideoRecorder.h"
#import <UIKit/UIKit.h>

@interface TBMHomeViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *friendViews;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *friendLabels;
@property TBMLongPressTouchHandler *longPressTouchHandler;
@property TBMVideoRecorder *videoRecorder;
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
    _longPressTouchHandler = [[TBMLongPressTouchHandler alloc] initWithTargetViews:_friendViews instantiator:self];
    
    NSError * error;
    _videoRecorder = [[TBMVideoRecorder alloc] initWithPreivewView:_centerView error:&error];
    if (!_videoRecorder){
        NSLog(@"%@", error);
    }
    
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
        NSLog(@"found %ld", (long)label.tag);
        if (label.tag == tag){
            return label;
        }
    }
    return nil;
}


//------------------------------------------
// Longpress touch handling for friend views
//------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesCancelled:touches withEvent:event];
    }
}

- (void)LPTHClickWithTargetView:(UIView *)view{
    NSLog(@"Holy shit it worked! click %ld", (long)view.tag);
}

- (void)LPTHStartLongPressWithTargetView:(UIView *)view{
    NSLog(@"Holy shit it worked! startLongPress %ld", (long)view.tag);
}

- (void)LPTHEndLongPressWithTargetView:(UIView *)view{
    NSLog(@"Holy shit it worked! endLongPressed %ld", (long)view.tag);
}

- (void)LPTHCancelLongPressWithTargetView:(UIView *)view{
    NSLog(@"Holy shit it worked! cancelLongPress %ld", (long)view.tag);
}


@end
