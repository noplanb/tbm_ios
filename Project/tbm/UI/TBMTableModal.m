//
//  TBMTableModal.m
//  SDCAlertViewControllerWithTableView
//
//  Created by Sani Elfishawy on 11/17/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMTableModal.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZContactDomainModel.h"

@interface TBMTableModal()

@property (nonatomic, strong)  NSString *title;
@property (nonatomic, strong)  UIView *parentView;
@property (nonatomic, strong)  NSArray *rowData;
@property (nonatomic, weak)  id <TBMTableModalDelegate> delegate;

@property (nonatomic, assign)  float titleHeight;
@property (nonatomic, assign)  int modalTag;

// UI elements
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIView *modalView;
@property(nonatomic, strong) UILabel *titleView;
@property(nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) ZZContactDomainModel* currentContact;

@end

static NSString *TBMTableReuseId = @"tableModalReuseId";

static const CGFloat cancelButtonHeight = 45.f;

@implementation TBMTableModal

- (void)setupViewWithParentView:(UIView *)parentView
                     title:(NSString *)title
                   contact:(ZZContactDomainModel*)contact
                  delegate:(id<TBMTableModalDelegate>)delegate
{
    _parentView = nil;
    _title = nil;
    _rowData = nil;
    _delegate = nil;
    _currentContact = nil;
    _modalView = nil;
    _tableView = nil;
    _cancelButton = nil;
    
    _parentView = parentView;
    _title = title;
    _rowData = contact.phones;
    _delegate = delegate;
    _titleHeight = 60;
    _modalTag = 93470095;
    _currentContact = contact;
    [self.tableView reloadData];
}

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

//--------------
// Show and hide
//--------------
- (void) show
{
    [self.parentView addSubview:[self dimParent]];
    [self.parentView addSubview:self.modalView];
}

- (void) hide
{
    for (UIView *v in [self.parentView subviews]){
        if (v.tag == self.modalTag)
            [v removeFromSuperview];
    }
}

#pragma mark - Handle events
- (void)cancelButtonTap:(id)sender
{
    [self hide];
}


//----------
// The Views
//----------
- (UIView *) dimParent
{
    UIView *dp = [[UIView alloc] initWithFrame:self.parentView.frame];
    [dp setBackgroundColor:[UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:0.8f]];
    dp.tag = self.modalTag;
    return dp;
}

#pragma mark -  Dimension calculations

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
    return self.titleHeight + [self tableHeight] + cancelButtonHeight;
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
    return [self maxModalHeight] - self.titleHeight;
}

- (float)tableHeight
{
    float fullHeight = [[self rowData] count] * [self tableCellHeight];
    return fminf(fullHeight, [self maxTableHeight]);
}

- (float)tableCellHeight
{
    return 44.0f;
}

//------------------------------
// Table Delegate and Datasource
//------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TBMTableReuseId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:TBMTableReuseId];
        
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0f];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0f];
    }

    NSInteger index = indexPath.row;
    
    ZZCommunicationDomainModel *model = [self.rowData objectAtIndex:index];
    
    [cell.textLabel setText:model.contact];
    [cell.detailTextLabel setText:model.label];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.rowData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentContact.primaryPhone = self.currentContact.phones[indexPath.row];
    [self.delegate updatePrimaryPhoneNumberForContact:self.currentContact];
    [self hide];
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = self.titleHeight;
        frame.size.width = [self modalWidth];
        frame.size.height = [self tableHeight];
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];

    }
    return _tableView;
}

- (UIView *)modalView {
    if (!_modalView) {
        CGRect frame;
        frame.origin.x = [self modalOriginX];
        frame.origin.y = [self modalOriginY];
        frame.size.width = [self modalWidth];
        frame.size.height = [self modalHeight];
        _modalView = [[UIView alloc] initWithFrame:frame];
        _modalView.tag = self.modalTag;
        [_modalView addSubview:self.titleView];
        [_modalView addSubview:self.tableView];
        [_modalView addSubview:self.cancelButton];
        _modalView.layer.masksToBounds = YES;
        _modalView.layer.cornerRadius = 5;
        _modalView.backgroundColor = [UIColor colorWithRed:0.95f green:0.94f blue:0.91f alpha:1.0f];
    }
    return _modalView;
}


- (UILabel *)titleView {
    if (!_titleView) {
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = [self modalWidth];
        frame.size.height = self.titleHeight;
        _titleView = [[UILabel alloc] initWithFrame:frame];
        [_titleView setText: self.title];
        _titleView.font = [UIFont fontWithName:@"Helvetica-Bold" size:21.0f];
        _titleView.textAlignment = NSTextAlignmentCenter;
        [_titleView setClipsToBounds:YES];
        _titleView.backgroundColor = [UIColor colorWithRed:0.96f green:0.55f blue:0.19f alpha:1.0f];
        _titleView.textColor = [UIColor whiteColor];
    }
    return _titleView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(self.tableView.frame);
        frame.size.width = [self modalWidth];
        frame.size.height = cancelButtonHeight;
        _cancelButton = [[UIButton alloc] initWithFrame:frame];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonTap:) forControlEvents:UIControlEventTouchDown];
    }
    return _cancelButton;
}


#pragma mark - Lazy initialization


@end
