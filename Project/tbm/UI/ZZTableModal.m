//
//  ZZTableModal.m
//  SDCAlertViewControllerWithTableView
//
//  Created by Sani Elfishawy on 11/17/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "ZZTableModal.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZContactDomainModel.h"
#import "ZZAlertTableStyle.h"

@import SDCAlertView;

@interface ZZTableModal()

@property (nonatomic, strong)  NSString *title;
@property (nonatomic, strong)  NSArray *rowData;
@property (nonatomic, weak)  id <TBMTableModalDelegate> delegate;
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZZContactDomainModel* currentContact;
@property (nonatomic, strong) SDCAlertController *alertController;

@end

static NSString *TBMTableReuseId = @"tableModalReuseId";

@implementation ZZTableModal

- (void)setupViewWithParentView:(UIView *)parentView
                     title:(NSString *)title
                   contact:(ZZContactDomainModel*)contact
                  delegate:(id<TBMTableModalDelegate>)delegate
{
    _tableView = nil;
    _title = title;
    _rowData = contact.phones;
    _delegate = delegate;
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

//-----
// Show
//-----

- (void) show
{
    self.alertController = [SDCAlertController alertControllerWithTitle:self.title
                                                                message:nil
                                                         preferredStyle:SDCAlertControllerStyleAlert];

    ZZAlertTableStyle *style = [ZZAlertTableStyle new];
    style.size = self.tableView.frame.size;
    self.alertController.visualStyle = style;

    [self.alertController.contentView addSubview:self.tableView];
    [self.alertController presentWithCompletion:nil];
    
    [self.alertController addAction:
     [SDCAlertAction actionWithTitle:@"Cancel"
                               style:SDCAlertActionStyleCancel
                             handler:nil]];
}

#pragma mark -  Dimension calculations

- (float)modalWidth
{
    return 0.85 * [self screenWidth];
}

- (float)screenWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}

- (float)screenHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float)maxModalHeight
{
    return 0.75 * [self screenHeight];
}

- (float)maxTableHeight
{
    return [self maxModalHeight];
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
    [self.alertController dismissWithCompletion:^{
        
        self.currentContact.primaryPhone = self.currentContact.phones[indexPath.row];
        [self.delegate updatePrimaryPhoneNumberForContact:self.currentContact];

    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = [self modalWidth];
        frame.size.height = [self tableHeight];
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];

    }
    return _tableView;
}

#pragma mark - Lazy initialization


@end
