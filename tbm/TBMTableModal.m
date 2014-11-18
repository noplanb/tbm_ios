//
//  TBMTableModal.m
//  SDCAlertViewControllerWithTableView
//
//  Created by Sani Elfishawy on 11/17/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMTableModal.h"

@interface TBMTableModal()
@property (nonatomic) NSString *title;
@property (nonatomic) UIView *parentView;
@property (nonatomic) NSArray *rowData;
@property (nonatomic) id <TBMTableModalDelegate> delegate;
@end

static float TBMTableModalTitleHeight = 50;
static int TBMTableModalTag = 9111;
static NSString *TBMTableReuseId = @"tableModalReuseId";

@implementation TBMTableModal

- (instancetype) initWithParentView:(UIView *)parentView
                              title:(NSString *)title
                            rowData:(NSArray*)rowData
                           delegate:(id<TBMTableModalDelegate>)delegate{
    self = [super init];
    if (self !=nil){
        _parentView = parentView;
        _title = title;
        _rowData = rowData;
        _delegate = delegate;
    }
    return self;
}

//--------------
// Show and hide
//--------------
- (void) show{
    [self.parentView addSubview:[self dimParent]];
    [self.parentView addSubview:[self modal]];
}

- (void) hide{
    for (UIView *v in [self.parentView subviews]){
        if (v.tag == TBMTableModalTag)
            [v removeFromSuperview];
    }
}

//----------
// The Views
//----------
- (UIView *) dimParent{
    UIView *dp = [[UIView alloc] initWithFrame:self.parentView.frame];
    [dp setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
    dp.tag = TBMTableModalTag;
    return dp;
}

- (UIView *) modal{
    CGRect f;
    f.origin.x = [self modalOriginX];
    f.origin.y = [self modalOriginY];
    f.size.width = [self modalWidth];
    f.size.height = [self modalHeight];
    UIView *modal = [[UIView alloc] initWithFrame:f];
    [modal addSubview:[self titleLabel]];
    [modal addSubview:[self table]];
    [modal setTag:9111];
    modal.layer.masksToBounds = YES;
    modal.layer.cornerRadius = 5;
    modal.backgroundColor = [UIColor colorWithWhite:255 alpha:1];
    return modal;
}

- (UILabel *)titleLabel{
    CGRect f;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = [self modalWidth];
    f.size.height = TBMTableModalTitleHeight;
    UILabel *title = [[UILabel alloc] initWithFrame:f];
    [title setText: self.title];
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;
    [title setClipsToBounds:YES];
    return title;
}

- (UITableView *)table{
    CGRect f;
    f.origin.x = 0;
    f.origin.y = TBMTableModalTitleHeight;
    f.size.width = [self modalWidth];
    f.size.height = [self tableHeight];
    UITableView *tv = [[UITableView alloc] initWithFrame:f];
    [tv setDelegate:self];
    [tv setDataSource:self];
    return tv;
}

//-----------------------
// Dimension calculations
//-----------------------
- (float) modalWidth{
    return 0.85 * [self screenWidth];
}

- (float) modalOriginX{
    return ([self screenWidth] - [self modalWidth]) / 2;
}

- (float) modalOriginY{
    return ([self screenHeight] - [self modalHeight]) / 2;
}

- (float) modalHeight{
    return TBMTableModalTitleHeight + [self tableHeight];
}

- (float)screenWidth{
    return [[UIScreen mainScreen] bounds].size.width;
}

- (float)screenHeight{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float)maxModalHeight{
    return 0.75 * [self screenHeight];
}

- (float)maxTableHeight{
    return [self maxModalHeight] - TBMTableModalTitleHeight;
}

- (float)tableHeight{
    NSLog(@"TableHeight: %ld %f ", (unsigned long)[[self rowData] count], [self tableCellHeight]);
    float fullHeight = [[self rowData] count] * [self tableCellHeight];
    return fminf(fullHeight, [self maxTableHeight]);
}

- (float)tableCellHeight{
    return [self cell].frame.size.height;
}

//------------------------------
// Table Delegate and Datasource
//------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:TBMTableReuseId];
    if (cell == nil)
        cell = [self cell];
    
    NSInteger i = indexPath.row;
    
    [cell.textLabel setText: [self mainTextWithIndex:i]];
    if ([self detailTextWithIndex:i] != nil)
        [cell.detailTextLabel setText:[self detailTextWithIndex:i]];
    return cell;
}

- (UITableViewCell *)cell{
    UITableViewCell *cell;
    id row0 = [self.rowData objectAtIndex:0];
    if ([row0 isKindOfClass: [NSArray class]])
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TBMTableReuseId];
    else
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TBMTableReuseId];
    return cell;
}

- (NSString *)mainTextWithIndex:(NSInteger)index{
    id data = [self.rowData objectAtIndex:index];
    if ([data isKindOfClass:[NSArray class]])
        return [data objectAtIndex:0];
    else
        return data;
}

- (NSString *)detailTextWithIndex:(NSInteger)index{
    id data = [self.rowData objectAtIndex:index];
    if ([data isKindOfClass:[NSArray class]])
        return [data objectAtIndex:1];
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.rowData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate didSelectRow:indexPath.row];
    [self hide];
}

@end
