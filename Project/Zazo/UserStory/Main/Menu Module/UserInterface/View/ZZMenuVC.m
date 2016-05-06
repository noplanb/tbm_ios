//
//  ZZMenuVC.m
//  Zazo
//

#import "ZZMenuVC.h"
#import "ZZMenu.h"
#import "ZZMenuView.h"
#import "ANMemoryStorage.h"
#import "ZZMenuController.h"
#import "ZZMenuCellModel.h"
#import "ZZMenuHeaderView.h"

@interface ZZMenuVC () <ZZMenuControllerDelegate>

@property (readonly) ZZMenuView *menuView;
@property (nonatomic, strong) ZZMenuController *controller;

@end

@implementation ZZMenuVC

@dynamic menuView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controller = [[ZZMenuController alloc] initWithTableView:self.menuView.tableView];
    self.controller.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_logoTap)];
    [self.menuView.headerView.titleLabel addGestureRecognizer:tapRecognizer];
    self.menuView.headerView.titleLabel.userInteractionEnabled = YES;
}

@synthesize storage = _storage;

- (void)setStorage:(ANMemoryStorage *)storage
{
    self.controller.storage = storage;
    _storage = storage;
}

- (void)loadView
{
    self.view = [ZZMenuView new];
}

- (ZZMenuView *)menuView
{
    return (id)self.view;
}

- (void)_logoTap
{
    [self.eventHandler titleTap];
}

#pragma mark Input

- (void)showUsername:(NSString *)username
{
#ifdef MAKING_SCREENSHOTS
    self.menuView.headerView.title = @"Jimmy Nelson";

#else
    self.menuView.headerView.title = username;
#endif
}

#pragma mark Menu Controller delegate

- (void)controller:(ZZMenuController *)controller didSelectModel:(ZZMenuCellModel *)model
{
    [self.eventHandler eventDidTapItemWithType:model.type];
}


@end
