//
//  TBMHomeViewController+Bench.m
//  tbm
//
//  Created by Sani Elfishawy on 11/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Bench.h"
#import "HexColor.h"
#import <objc/runtime.h>
#import "TBMConfig.h"
#import "TBMGridManager.h"
#import "TBMFriend.h"

static NSString *BENCH_BACKGROUND_COLOR = @"#555";
static NSString *BENCH_TEXT_COLOR = @"#fff";
static NSString *BENCH_CELL_REUSE_ID = @"benchCell";


@implementation TBMHomeViewController (Bench)

//-----------------------------------------
// Instance variables as associated objects
//-----------------------------------------
// @property benchView
// @property benchTable
// @property searchBar
- (void)setBenchView:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(benchView), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)benchView {
    return (UIView *)objc_getAssociatedObject(self, @selector(benchView));
}

- (void)setBenchTable:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(benchTable), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UITableView *)benchTable {
    return (UITableView *)objc_getAssociatedObject(self, @selector(benchTable));
}

- (void)setsearchBar:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(searchBar), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UISearchBar *)searchBar {
    return (UISearchBar *)objc_getAssociatedObject(self, @selector(searchBar));
}



//----------------
// Setup the views
//----------------
- (void)setupBenchView{
    [self addGestureRecognizers];
    [self makeBenchView];
    [self makeSearchBar];
    [self makeBenchTable];
    
    [[self benchView] addSubview:[self searchBar]];
    [[self benchView] addSubview:[self benchTable]];
    [[self view] addSubview:[self benchView]];
    [[self view] setNeedsDisplay];
}

- (void)addGestureRecognizers{
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
    [self setsearchBar:sb];
}

- (void)makeBenchTable{
    UITableView *bt = [[UITableView alloc] initWithFrame:[self benchTableRect]];
    [bt setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR alpha:1]];
    [bt setDataSource:self];
    [bt setDelegate:self];
    [self setBenchTable:bt];
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


//------------------------------------------------
// Bench TableView Delegate and Datasource methods
//------------------------------------------------
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BENCH_CELL_REUSE_ID];
    if (cell == nil)
        cell = [self benchCell];
    
    id item = [[self benchTableArray] objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[TBMFriend class]]){
        TBMFriend *f = (TBMFriend *)item;
        cell.imageView.image = [f thumbImageOrThumbMissingImage];
        cell.textLabel.text = f.firstName;
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = item;
    }

    return cell;
}

- (UITableViewCell *)benchCell{
    UITableViewCell *bc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BENCH_CELL_REUSE_ID];
    [bc setBackgroundColor:[UIColor colorWithHexString:BENCH_BACKGROUND_COLOR]];
    bc.textLabel.textColor = [UIColor colorWithHexString:BENCH_TEXT_COLOR alpha:1];
    return bc;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self benchTableArray] count];
}

//--------------------------
// Bench Table backing array
//--------------------------
- (NSMutableArray *)benchTableArray{
    NSMutableArray *bta = [[NSMutableArray alloc] initWithArray:[TBMGridManager friendsOnBench]];
    [bta addObjectsFromArray:[self items]];
    return bta;
}

- (NSArray *)items{
    NSArray *r = [[NSArray alloc] initWithObjects: @"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    return r;
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
    CGRect f = [self benchView].frame;
    f.origin.x = [self shownX];
    [UIView animateWithDuration:0.2 animations:^{
        [self benchView].frame = f;
    }];
}

- (void)hide{
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

@end
