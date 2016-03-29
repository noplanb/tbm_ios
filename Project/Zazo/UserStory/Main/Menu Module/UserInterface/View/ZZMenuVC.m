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

@interface ZZMenuVC ()

@property (readonly) ZZMenuView *menuView;
@property (nonatomic, strong) ZZMenuController *controller;

@end

@implementation ZZMenuVC

@dynamic menuView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controller = [[ZZMenuController alloc] initWithTableView:self.menuView.tableView];
    self.controller.storage = [self _makeStorage];
}

- (ANMemoryStorage *)_makeStorage
{
    ANMemoryStorage *storage = [ANMemoryStorage storage];

    ZZMenuCellModel *inviteFriends =
            [ZZMenuCellModel modelWithTitle:@"Invite friends" iconWithImageNamed:@"invite-friends"];

    ZZMenuCellModel *editFriends=
            [ZZMenuCellModel modelWithTitle:@"Edit Zazo friends" iconWithImageNamed:@"edit-friends"];

    ZZMenuCellModel *contacts =
            [ZZMenuCellModel modelWithTitle:@"Contacts" iconWithImageNamed:@"contacts"];

    ZZMenuCellModel *settings =
            [ZZMenuCellModel modelWithTitle:@"Setting" iconWithImageNamed:@"settings"];

    ZZMenuCellModel *helpFeedback =
            [ZZMenuCellModel modelWithTitle:@"Help & feedback" iconWithImageNamed:@"feedback"];

    [storage addItem:inviteFriends toSection:0];
    [storage addItem:editFriends toSection:1];
    [storage addItem:contacts toSection:1];
    [storage addItem:settings toSection:2];
    [storage addItem:helpFeedback toSection:2];

    return storage;
}

- (void)loadView
{
    self.view = [ZZMenuView new];
}

- (ZZMenuView *)menuView
{
    return (id)self.view;
}

@end
