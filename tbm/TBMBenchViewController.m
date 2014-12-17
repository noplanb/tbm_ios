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
}


//----------------
// Setup the views
//----------------
static NSString *BENCH_BACKGROUND_COLOR = @"#555";
static NSString *BENCH_TEXT_COLOR = @"#fff";
static NSString *BENCH_CELL_REUSE_ID = @"benchCell";

- (void)setupBenchView{
    self.view.frame = [self benchRect];
    self.view.backgroundColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1];
    [self addBenchGestureRecognizers];
    [self makeSearchBar];
    [self getAndSetTableArray];
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


- (void)makeSearchBar{
    UISearchBar *sb = [[UISearchBar alloc] initWithFrame:[self searchBarRect]];
    sb.placeholder = @"Search";
    sb.searchBarStyle = UISearchBarStyleProminent;
    sb.barTintColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR];
    sb.delegate = self;
    sb.showsCancelButton = NO;
    self.searchBar = sb;
}

- (void)makeBenchTable{
    UITableView *bt = [[UITableView alloc] initWithFrame:[self benchTableRect] style:UITableViewStylePlain];
    [bt setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    [bt setDataSource:self];
    [bt setDelegate:self];
    self.benchTable = bt;
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
    sbRect.size.height = 35.0f;
    sbRect.size.width = [self benchRect].size.width;
    sbRect.origin.x = 0;
    sbRect.origin.y = 0;
    return sbRect;
}

- (CGRect) benchTableRect{
    CGRect br = [self benchRect];
    CGRect sbr = [self searchBarRect];
    
    CGRect btRect;
    btRect.origin.x = 0;
    btRect.origin.y = sbr.size.height;
    
    btRect.size.width = br.size.width;
    btRect.size.height = br.size.height - sbr.size.height;
    
    return btRect;
}

- (CGRect) searchTableRect{
    CGRect r = [self benchTableRect];
    r.size.height = [[UIScreen mainScreen] bounds].size.height / 2;
    return r;
}


//------------------------------------------------
// Bench TableView Delegate and Datasource methods
//------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BENCH_CELL_REUSE_ID];
    if (cell == nil)
        cell = [self benchCell];
    
    id item = [self.tableArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[TBMFriend class]]){
        TBMFriend *f = (TBMFriend *)item;
        NSURL *url = [f thumbUrl];
        if (url !=nil){
            cell.imageView.image = [UIImage imageWithContentsOfFile:url.path];
        } else {
            //TODO add the zazo image here
        }
        cell.textLabel.text = f.firstName;
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = item;
    }
    
    return cell;
}

- (UITableViewCell *)benchCell{
    UITableViewCell *bc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BENCH_CELL_REUSE_ID];
    [bc setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    bc.textLabel.textColor = [UIColor colorWithHexString:BENCH_TEXT_COLOR alpha:1];
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
- (void) getAndSetTableArray{
    NSMutableArray *bta = [[NSMutableArray alloc] initWithArray:[self.gridViewController friendsOnBench]];
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
    [self.benchTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect f = self.view.frame;
    f.origin.x = [self shownX];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = f;
    }];
    self.isShowing = YES;
}

- (void)reloadData{
    [self getAndSetTableArray];
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
