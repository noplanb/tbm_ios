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
    self.controller.storage = [self _makeStorage];
    self.controller.delegate = self;
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

    ZZMenuCellModel *helpFeedback =
            [ZZMenuCellModel modelWithTitle:@"Help & feedback" iconWithImageNamed:@"feedback"];

    inviteFriends.type = ZZMenuItemTypeEditFriends;
    editFriends.type = ZZMenuItemTypeEditFriends;
    contacts.type = ZZMenuItemTypeContacts;
    helpFeedback.type = ZZMenuItemTypeHelp;

    [storage addItem:inviteFriends toSection:0];
    [storage addItem:editFriends toSection:0];
    [storage addItem:contacts toSection:0];
    [storage addItem:helpFeedback toSection:0];

#ifdef DEBUG

    ZZMenuCellModel *secretScreen =
            [ZZMenuCellModel modelWithTitle:@"Secret screen" iconWithImageNamed:@"settings"];

    secretScreen.type = ZZMenuItemTypeSecretScreen;
    [storage addItem:secretScreen toSection:0];

#endif

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

#pragma mark Input

- (void)showUsername:(NSString *)username
{
    self.menuView.headerView.title = username;
}

#pragma mark Menu Controller delegate

- (void)controller:(ZZMenuController *)controller didSelectModel:(ZZMenuCellModel *)model
{
    [self.eventHandler eventDidTapItemWithType:model.type];
}


@end
