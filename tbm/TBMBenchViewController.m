//
//  TBMBenchViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 12/16/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMBenchViewController.h"
#import "TBMHomeViewController+Invite.h"
#import "HexColor.h"
#import <objc/runtime.h>
#import "TBMConfig.h"
#import "TBMFriend.h"
#import "TBMContactsManager.h"
#import "OBLogger.h"
#import "TBMContactSearchTableDelegate.h"
#import "TBMBenchTableViewCell.h"

@interface TBMBenchViewController ()
@property (nonatomic) TBMGridViewController *gridViewController;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UITableView *benchTable;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSArray *tableArray;
@property (nonatomic) UITableView *searchTable;
@property (nonatomic) TBMContactSearchTableDelegate *searchTableDelegate;
@end

@implementation TBMBenchViewController

//--------------
// Instantiation
//--------------
static TBMBenchViewController *existingInstance = nil;

- (instancetype)initWithContainerView:(UIView *)containerView gridViewController:(TBMGridViewController *)gridViewController{
    self = [super init];
    if (self != nil){
        _gridViewController = gridViewController;
        _containerView = containerView;
        [self setupBenchView];
        existingInstance = self;
    }
    return self;
}

+ (TBMBenchViewController *)existingInstance{
    return existingInstance;
}

//----------
// Lifecycle
//----------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register for keyboard did show notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification  object:nil];
}


//----------------
// Setup the views
//----------------
static NSString *BENCH_BACKGROUND_COLOR = @"#2F2E28";
static NSString *BENCH_TEXT_COLOR = @"#A8A295";
static NSString *BENCH_CELL_REUSE_ID = @"benchCell";
static float BENCH_CELL_HEIGHT = 56.0;

- (void)setupBenchView{
    self.view.frame = [self benchRect];
    self.view.backgroundColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1];
    
    self.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.view.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
    self.view.layer.shadowOpacity = 0.7f;
    self.view.layer.shadowRadius = 4.0f;
    
    [self addBenchGestureRecognizers];
    [self makeSearchBar];
    [self getAndSetTableArrayAddContacts:NO];
    [self makeBenchTable];
    [self makeSearchTable];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.benchTable];
    [self.view addSubview:self.searchTable];
    [[self view] setNeedsDisplay];
    [self hide];
    [self hideSearch];
}

- (void)addBenchGestureRecognizers{
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    sgr.direction = UISwipeGestureRecognizerDirectionRight;
    [self.containerView addGestureRecognizer:sgr];
    
    UISwipeGestureRecognizer *sgl = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
    sgr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.containerView addGestureRecognizer:sgl];
}


- (void)makeSearchBar {
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:16]}];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTintColor:[UIColor whiteColor]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTextColor:[UIColor whiteColor]];

    UISearchBar *sb = [[UISearchBar alloc] initWithFrame:[self searchBarRect]];
    sb.placeholder = @"";
    sb.searchBarStyle = UISearchBarStyleMinimal;
    sb.delegate = self;
    sb.showsCancelButton = NO;
    [sb setSearchTextPositionAdjustment:UIOffsetMake(4.0f, 0.0f)];
    [sb setSearchFieldBackgroundImage:[UIImage imageNamed:@"search-field-bg"] forState:UIControlStateNormal];
    
    self.searchBar = sb;
}

- (void)makeBenchTable{
    UITableView *bt = [[UITableView alloc] initWithFrame:[self benchTableRect] style:UITableViewStylePlain];
    [bt setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    [bt setDataSource:self];
    [bt setDelegate:self];
    bt.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.benchTable = bt;
    
    UIView *botBorderTopView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, bt.frame.origin.y - 2.0f, bt.frame.size.width, 1.0f)];
    botBorderTopView.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:1.0f];
    [self.view addSubview:botBorderTopView];
    
    UIView *botBorderBotView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, bt.frame.origin.y - 1.0f, bt.frame.size.width, 1.0f)];
    botBorderBotView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.33 alpha:1.0f];
    [self.view addSubview:botBorderBotView];
}

- (void)makeSearchTable{
    self.searchTableDelegate = [[TBMContactSearchTableDelegate alloc] initWithSelectCallback:^(NSString *fullname) {
        [self searchContactSelected:fullname];
    }];
    self.searchTableDelegate.cellBackgroundColor = BENCH_BACKGROUND_COLOR;
    self.searchTableDelegate.cellTextColor = BENCH_TEXT_COLOR;
    self.searchTable = [[UITableView alloc] initWithFrame:[self searchTableRect] style:UITableViewStylePlain];
    self.searchTable.backgroundColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1];
    self.searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchTable.hidden = NO;
    self.searchTable.delegate = self.searchTableDelegate;
    self.searchTable.dataSource = self.searchTableDelegate;
}


//------------------------------------------
// Size and origin calculatons for the views
//------------------------------------------

- (CGRect)benchRect{
    float x = self.containerView.frame.size.width/4;
    float w = 3.0 * self.containerView.frame.size.width / 4.0;
    return CGRectMake(x, 0, w, self.containerView.frame.size.height);
}

- (CGRect) searchBarRect{
    CGRect sbRect;
    sbRect.size.height = 30.0f;
    sbRect.size.width = [self benchRect].size.width - 20.0f;
    sbRect.origin.x = 10;
    sbRect.origin.y = 20;
    return sbRect;
}

- (CGRect) benchTableRect{
    CGRect br = [self benchRect];
    CGRect sbr = [self searchBarRect];
    
    CGRect btRect;
    btRect.origin.x = 0;
    btRect.origin.y = sbr.size.height + sbr.origin.y + 20.0;
    
    btRect.size.width = br.size.width;
    btRect.size.height = br.size.height - sbr.size.height - sbr.origin.y - 20.0;
    
    return btRect;
}

- (CGRect) searchTableRect{
    CGRect r = [self benchTableRect];
    r.size.height = [[UIScreen mainScreen] bounds].size.height / 2;
    return r;
}


//-------------------------------
// Keyboard did show notification
//-------------------------------

-(void)keyboardDidShow:(NSNotification*)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // Resize search table so it is not covered up by keboard
    CGRect searchTableFrame = self.searchTable.frame;
    searchTableFrame.size.height = [self benchTableRect].size.height - keyboardHeight;
    self.searchTable.frame = searchTableFrame;
}


//------------------------------------------------
// Bench TableView Delegate and Datasource methods
//------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BENCH_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TBMBenchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BENCH_CELL_REUSE_ID];
    if (cell == nil)
        cell = [self benchCell];
    
    // NSLog(@"table view width: %f", tableView.frame.size.width);
    
    CGRect nameFrame = cell.nameLabel.frame;
    
    id item = [self.tableArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[TBMFriend class]]){
        TBMFriend *f = (TBMFriend *)item;
        NSURL *url = [f thumbUrl];
        if (url !=nil){
            cell.thumbImageView.image = [UIImage imageWithContentsOfFile:url.path];
        } else {
            cell.thumbImageView.image = [UIImage imageNamed:@"icon-no-pic"];
        }
        cell.nameLabel.text = [f displayName];
        nameFrame.origin.x = cell.thumbImageView.frame.origin.x + cell.thumbImageView.frame.size.width + BENCH_CELL_THUMB_IMAGE_RIGHT_MARGIN;
    } else {
        cell.thumbImageView.image = nil;
        cell.nameLabel.text = item;
        nameFrame.origin.x = cell.thumbImageView.frame.origin.x;
    }
    
    nameFrame.size.width = tableView.frame.size.width - nameFrame.origin.x - BENCH_CELL_THUMB_IMAGE_RIGHT_MARGIN;
    cell.nameLabel.frame = nameFrame;
    
    return cell;
}

- (TBMBenchTableViewCell *)benchCell{
    TBMBenchTableViewCell *bc = [[TBMBenchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BENCH_CELL_REUSE_ID];
    [bc setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    bc.nameLabel.textColor = [UIColor colorWithHexString:BENCH_TEXT_COLOR alpha:1];
    return bc;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hide];
    id obj = [self.tableArray objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[TBMFriend class]]){
        TBMFriend *f = (TBMFriend *) obj;
        [self.gridViewController moveFriendToGrid:f];
    }else{
        [(TBMHomeViewController *) self.parentViewController invite:obj];
    }
}

- (BOOL)canGetContacts{
    return [[TBMContactsManager sharedInstance] getFullNamesHavingAnyPhone] != nil;
}


//--------------------------
// Bench Table backing array
//--------------------------
- (void) getAndSetTableArrayAddContacts:(BOOL)addContacts{
    NSMutableArray *bta = [[NSMutableArray alloc] initWithArray:[self.gridViewController friendsOnBench]];
    if (addContacts)
        [bta addObjectsFromArray:[[TBMContactsManager sharedInstance] getFullNamesHavingAnyPhone]];
    self.tableArray = bta;
    DebugLog(@"getAndSetTableArray (%ld)", (unsigned long)[self.tableArray count]);
}


//--------------
// Show and hide
//--------------
- (void)handleSwipeRight{
    [self show];
}

- (void)handleSwipeLeft{
    [self hide];
}

- (void)toggle{
    if (self.isShowing){
        [self hide];
    } else {
        [self show];
    }
}

- (void)show{
    if (![self canGetContacts]){
        OB_ERROR(@"Bench: show: not showing bench becuase could not get contacts");
        return;
    }
    [self reloadData];
    
    if ([self.tableArray count] > 0) {
        [self.benchTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                               atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    CGRect f = self.view.frame;
    f.origin.x = [self shownX];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = f;
    }];
    self.isShowing = YES;
    
    if ([self.delegate respondsToSelector:@selector(TBMBenchViewController:toggledHidden:)]) {
        [self.delegate TBMBenchViewController:self toggledHidden:NO];
    }
}

- (void)reloadData{
    [self getAndSetTableArrayAddContacts:YES];
    [self.benchTable reloadData];
}

- (void)hide{
    [self hideSearch];
    CGRect f = self.view.frame;
    f.origin.x = [self hiddenX];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = f;
    }];
    self.isShowing = NO;
    
    if ([self.delegate respondsToSelector:@selector(TBMBenchViewController:toggledHidden:)]) {
        [self.delegate TBMBenchViewController:self toggledHidden:YES];
    }
}

- (NSInteger)shownX{
    return [UIScreen mainScreen].bounds.size.width - self.view.frame.size.width;
}

- (NSInteger)hiddenX{
    return [UIScreen mainScreen].bounds.size.width;
}


//-------------------
// Search bar control
//-------------------
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchTableDelegate.dataArray = [[NSArray alloc] init];
    [self.searchTable reloadData];
    [self showSearch];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.searchTableDelegate.dataArray = [[TBMContactsManager sharedInstance] fullnamesMatchingSubstr:searchText limit:10];
    [self.searchTable reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self hideSearch];
}


- (void)showSearch{
    self.benchTable.hidden = YES;
    self.searchTable.hidden = NO;
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)hideSearch{
    self.searchTable.hidden = YES;
    self.benchTable.hidden = NO;
    self.searchBar.text = nil;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchContactSelected:(NSString *)fullname{
    [self hide];
    [(TBMHomeViewController *)self.parentViewController invite:fullname];
}
@end
