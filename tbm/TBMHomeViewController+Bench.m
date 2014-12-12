//
//  TBMHomeViewController+Bench.m
//  tbm
//
//  Created by Sani Elfishawy on 11/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+Bench.h"
#import "TBMGridViewController.h"
#import "TBMHomeViewController+Invite.h"
#import "HexColor.h"
#import <objc/runtime.h>
#import "TBMConfig.h"
#import "TBMFriend.h"
#import "TBMContactsManager.h"
#import "OBLogger.h"
#import "TBMContactSearchTableDelegate.h"

static NSString *BENCH_BACKGROUND_COLOR = @"#555";
static NSString *BENCH_TEXT_COLOR = @"#fff";
static NSString *BENCH_CELL_REUSE_ID = @"benchCell";


@implementation TBMHomeViewController (Bench)

//-----------------------------------------
// Instance variables as associated objects
//-----------------------------------------
// @property benchView
- (void)setBenchView:(UIView *)obj {
    objc_setAssociatedObject(self, @selector(benchView), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)benchView {
    return (UIView *)objc_getAssociatedObject(self, @selector(benchView));
}
// @property benchTable
- (void)setBenchTable:(UITableView *)obj {
    objc_setAssociatedObject(self, @selector(benchTable), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UITableView *)benchTable {
    return (UITableView *)objc_getAssociatedObject(self, @selector(benchTable));
}
// @property searchBar
- (void)setsearchBar:(UISearchBar *)obj {
    objc_setAssociatedObject(self, @selector(searchBar), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UISearchBar *)searchBar {
    return (UISearchBar *)objc_getAssociatedObject(self, @selector(searchBar));
}
// @property tableArray
- (void)setTableArray:(NSArray *)obj {
    objc_setAssociatedObject(self, @selector(tableArray), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray *)tableArray {
    return (NSArray *)objc_getAssociatedObject(self, @selector(tableArray));
}
// @property isSetup
- (void)setIsSetup:(BOOL)obj {
    objc_setAssociatedObject(self, @selector(isSetup), [NSNumber numberWithBool:obj], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isSetup {
    return [objc_getAssociatedObject(self, @selector(isSetup)) boolValue];
}
// @property searchTable
- (void)setSearchTable:(UITableView *)obj{
    objc_setAssociatedObject(self, @selector(searchTable), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UITableView *)searchTable{
    return objc_getAssociatedObject(self, @selector(searchTable));
}
// @property searchTableDelegate
- (void)setSearchTableDelegate:(TBMContactSearchTableDelegate *)obj{
    objc_setAssociatedObject(self, @selector(searchTableDelegate), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TBMContactSearchTableDelegate *)searchTableDelegate{
    return objc_getAssociatedObject(self, @selector(searchTableDelegate));
}

//----------------
// Setup the views
//----------------
- (void)setupBenchView{
    if ([self isSetup]){
        OB_INFO(@"Bench: already setup");
        return;
    }
    
    [self addBenchGestureRecognizers];
    [self makeBenchView];
    [self makeSearchBar];
    [self getAndSetTableArray];
    [self makeBenchTable];
    [self makeSearchTable];
    
    [[self benchView] addSubview:[self searchBar]];
    [[self benchView] addSubview:[self benchTable]];
    [[self benchView] addSubview:[self searchTable]];
    [[self view] addSubview:[self benchView]];
    [[self view] setNeedsDisplay];
    [self hide];
    [self hideSearch];
    [self setIsSetup:YES];
}

- (void)addBenchGestureRecognizers{
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    sgr.direction = UISwipeGestureRecognizerDirectionRight;
    [[self view] addGestureRecognizer:sgr];
    
    UISwipeGestureRecognizer *sgl = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
    sgr.direction = UISwipeGestureRecognizerDirectionLeft;
    [[self view] addGestureRecognizer:sgl];
}

- (void)makeBenchView{
    UIView *bv = [[UIView alloc] initWithFrame:[self benchRect]];
    [bv setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    [self setBenchView:bv];
}

- (void)makeSearchBar{
    UISearchBar *sb = [[UISearchBar alloc] initWithFrame:[self searchBarRect]];
    sb.placeholder = @"Search";
    sb.searchBarStyle = UISearchBarStyleProminent;
    sb.barTintColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR];
    sb.delegate = self;
    sb.showsCancelButton = NO;
    [self setsearchBar:sb];
}

- (void)makeBenchTable{
    UITableView *bt = [[UITableView alloc] initWithFrame:[self benchTableRect] style:UITableViewStylePlain];
    [bt setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    [bt setDataSource:self];
    [bt setDelegate:self];
    [self setBenchTable:bt];
}

- (void)makeSearchTable{
    [self setSearchTableDelegate: [[TBMContactSearchTableDelegate alloc] initWithSelectCallback:^(NSString *fullname) {
        [self searchContactSelected:fullname];
    }]];
    [self searchTableDelegate].cellBackgroundColor = BENCH_BACKGROUND_COLOR;
    [self searchTableDelegate].cellTextColor = BENCH_TEXT_COLOR;
    [self setSearchTable: [[UITableView alloc] initWithFrame:[self searchTableRect] style:UITableViewStylePlain]];
    [self searchTable].backgroundColor = [UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1];
    [self searchTable].separatorStyle = UITableViewCellSeparatorStyleNone;
    [self searchTable].hidden = NO;
    [self searchTable].delegate = [self searchTableDelegate];
    [self searchTable].dataSource = [self searchTableDelegate];
}



//------------------------------------------
// Size and origin calculatons for the views
//------------------------------------------

- (CGRect)benchRect{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect benchRect;
    
    CGSize benchSize;
    benchSize.width = 3.0 * screenRect.size.width / 4.0;
    benchSize.height = screenRect.size.height - statusBarHeight;
    
    CGPoint benchOrigin;
    benchOrigin.y = statusBarHeight;
    benchOrigin.x = screenRect.origin.x + (screenRect.size.width/4.0);
    
    benchRect.size = benchSize;
    benchRect.origin = benchOrigin;
    return benchRect;
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
    
    id item = [[self tableArray] objectAtIndex:indexPath.row];
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
    return [[self tableArray] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hide];
    id obj = [[self tableArray] objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[TBMFriend class]]){
        TBMFriend *f = (TBMFriend *) obj;
        [self.gridViewController moveFriendToGrid:f];
    }else{
        [self invite:obj];
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
    [self setTableArray:bta];
    DebugLog(@"getAndSetTableArray (%ld)", (unsigned long)[[self tableArray] count]);
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

- (void)show{
    if (![self canGetContacts]){
        OB_ERROR(@"Bench: show: not showing bench becuase could not get contacts");
        return;
    }
    [self setupBenchView];
    [self reloadData];
    [[self benchTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect f = [self benchView].frame;
    f.origin.x = [self shownX];
    [UIView animateWithDuration:0.2 animations:^{
        [self benchView].frame = f;
    }];
}

- (void)reloadData{
    [self getAndSetTableArray];
    [[self benchTable] reloadData];
}

- (void)hide{
    [self hideSearch];
    CGRect f = [self benchView].frame;
    f.origin.x = [self hiddenX];
    [UIView animateWithDuration:0.2 animations:^{
        [self benchView].frame = f;
    }];
}

- (NSInteger)shownX{
    return [UIScreen mainScreen].bounds.size.width - [self benchView].frame.size.width;
}

- (NSInteger)hiddenX{
    return [UIScreen mainScreen].bounds.size.width;
}


//-------------------
// Search bar control
//-------------------
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self searchTableDelegate].dataArray = [[NSArray alloc] init];
    [[self searchTable] reloadData];
    [self showSearch];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchTableDelegate].dataArray = [[TBMContactsManager sharedInstance] fullnamesMatchingSubstr:searchText limit:10];
    [[self searchTable] reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self hideSearch];
}


- (void)showSearch{
    [self benchTable].hidden = YES;
    [self searchTable].hidden = NO;
    [[self searchBar] setShowsCancelButton:YES animated:YES];
}

- (void)hideSearch{
    [self searchTable].hidden = YES;
    [self benchTable].hidden = NO;
    [self searchBar].text = nil;
    [[self searchBar] setShowsCancelButton:NO animated:YES];
    [[self searchBar] resignFirstResponder];
}

- (void)searchContactSelected:(NSString *)fullname{
    [self hide];
    [self invite:fullname];
}
@end
