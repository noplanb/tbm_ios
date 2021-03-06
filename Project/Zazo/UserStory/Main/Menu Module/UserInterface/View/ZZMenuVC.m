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

    self.controller =
        [[ZZMenuController alloc] initWithTableView:self.menuView.tableView];
    self.controller.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_didTapUsername)];
    
    [self.menuView.headerView.titleLabel addGestureRecognizer:tapRecognizer];
    self.menuView.headerView.titleLabel.userInteractionEnabled = YES;
    
    [self.menuView.headerView.imageViewButton addTarget:self
                                                 action:@selector(_didTapAvatar)
                                       forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *editIcon = [UIImage imageNamed:@"avatar-edit-icon"];
    UIImageView *editView = [[UIImageView alloc] initWithImage:editIcon];
    [self.menuView.headerView addSubview:editView];
    
    [editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.menuView.headerView.imageView);
    }];
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

- (void)_didTapUsername
{
    [self.eventHandler didTapUsername];
}

- (void)_didTapAvatar
{
    [self.eventHandler didTapAvatar];
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
