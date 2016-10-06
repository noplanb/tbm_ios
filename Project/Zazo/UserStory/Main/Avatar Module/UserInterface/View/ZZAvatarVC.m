//
//  ZZAvatarVC.m
//  Zazo
//

#import "ZZAvatarVC.h"
#import "ZZAvatar.h"
#import "ANMemoryStorage.h"
#import "ZZMenuController.h"
#import "ZZMenuCellModel.h"
#import "ZZMenuHeaderView.h"
#import "ZZMenuView.h"

@interface ZZAvatarVC () <ZZMenuControllerDelegate>

@property (nonatomic, strong) ZZMenuView *menuView;
@property (nonatomic, strong) ZZMenuController *controller;

@end

@implementation ZZAvatarVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuView = [ZZMenuView new];
    }
    return self;
}

- (void)loadView
{
    self.view = self.menuView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Avatar";
    
    self.controller =
    [[ZZMenuController alloc] initWithTableView:self.menuView.tableView];
    self.controller.delegate = self;
    
    [self.menuView.headerView.imageViewButton addTarget:self
                                                 action:@selector(_didTapAvatar)
                                       forControlEvents:UIControlEventTouchUpInside];

    self.menuView.headerView.layoutMargins = UIEdgeInsetsMake(48, 24, 48, 24);
    self.menuView.headerView.avatarRadius = 80;
}

- (void)askForRetry:(NSString *)message completion:(void (^ _Nonnull)(BOOL confirmed))completion
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Operation failed" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion(true);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completion(false);
    }];
    
    [alert addAction:retry];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)_didTapAvatar
{
    [self.eventHandler didTapAvatar];
}

- (void)showLoading:(BOOL)visible
{
    if (visible)
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

@synthesize storage = _storage;

- (void)setStorage:(ANMemoryStorage *)storage
{
    self.controller.storage = storage;
    _storage = storage;
}

- (void)showAvatar:(UIImage *)image
{
    self.menuView.headerView.imageView.image = image;
}


#pragma mark Menu Controller delegate

- (void)controller:(ZZMenuController *)controller didSelectModel:(ZZMenuCellModel *)model
{
    [self.eventHandler eventDidTapItemWithType:model.type];
}

@end
