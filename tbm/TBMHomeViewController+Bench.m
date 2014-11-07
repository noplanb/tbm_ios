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
- (id)benchView {
    return objc_getAssociatedObject(self, @selector(benchView));
}

- (void)setBenchTable:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(benchTable), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)benchTable {
    return objc_getAssociatedObject(self, @selector(benchTable));
}

- (void)setsearchBar:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(searchBar), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)searchBar {
    return objc_getAssociatedObject(self, @selector(searchBar));
}

//----------------
// Setup the views
//----------------
- (void)setupBench{
    [self makeBenchView];
    [self makeSearchBar];
    [self makeBenchTable];
    
    [[self benchView] addSubview:[self searchBar]];
    [[self benchView] addSubview:[self benchTable]];
    [[self view] addSubview:[self benchView]];
    [[self view] setNeedsDisplay];

}

- (void)makeBenchView{
    UIView *bv = [[UIView alloc] initWithFrame:[self benchRect]];
    [bv setBackgroundColor:[UIColor colorWithHexString:@"#555" alpha:1]];
    [self setBenchView:bv];
}

- (void)makeSearchBar{
    UISearchBar *sb = [[UISearchBar alloc] initWithFrame:[self searchBarRect]];
    sb.placeholder = @"Search";
    sb.searchBarStyle = UISearchBarStyleProminent;
    [self setsearchBar:sb];
}

- (UITableView *)makeBenchTable{
    UITableView *bt = [[UITableView alloc] initWithFrame:[self benchTableRect]];
    return bt;
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
    btRect.origin.x = br.origin.x;
    btRect.origin.y = br.origin.y + sbr.size.height;
    
    btRect.size.width = br.size.width;
    btRect.size.height = br.size.height - sbr.size.height;
    
    return btRect;
}

@end
