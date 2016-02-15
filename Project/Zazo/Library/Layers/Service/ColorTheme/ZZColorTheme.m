//
//  ZZColorTheme.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZColorTheme.h"

static CGFloat const kNavigationBarIconHeight = 20;

@interface ZZColorTheme ()

@property (nonatomic, strong) UIColor* navBarbackgroundColor;
@property (nonatomic, strong) UIColor* navBarFontColor;

@end

@implementation ZZColorTheme

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

+ (void)load
{
    [self setupFonts];
}

+ (void)setupFonts
{
    [UIFont an_addFontName:@"SFUIText-Light" forType:ANFontTypeLight];
    [UIFont an_addFontName:@"SFUIText" forType:ANFontTypeRegular];
    [UIFont an_addFontName:@"SFUIText-Medium" forType:ANFontTypeMedium];
    [UIFont an_addFontName:@"SFUIText-Bold" forType:ANFontTypeBold];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //TODO: convert in HEX

        self.authBackgroundColor = [UIColor an_colorWithHexString:@"#9CBE45"];
        self.gridBackgourndColor = [UIColor an_colorWithHexString:@"#eeeeee"];
        
        self.gridMenuColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.16 alpha:1];

        self.baseColor = [UIColor an_colorWithHexString:@"ac1e44"];
        
        self.navBarFontColor = [UIColor whiteColor];
        self.textGrayColor = [UIColor an_colorWithHexString:@"7b7b81"];
        self.textLightGrayColor = [UIColor an_colorWithHexString:@"8e8e93"];
        
        self.baseBackgroundColor = [UIColor an_colorWithHexString:@"ebebf1"];
        self.baseFontColor = [UIColor an_colorWithHexString:@"5B5B5B"];
        
        self.baseCellTextColor = [UIColor an_colorWithHexString:@"202020"];
        
        self.gridCellLayoutGreenColor = [UIColor an_colorWithHexString:@"#9BBF45"];
        self.gridCellGrayColor = [UIColor an_colorWithHexString:@"#4D4C40"];
        self.gridCellTextColor = [UIColor an_colorWithHexString:@"#ffffff"];
        self.gridCellBorderColor = [UIColor an_colorWithHexString:@"#ffffff"];
        self.gridCellBackgroundColor = [UIColor an_colorWithHexString:@"#f8f8f8"];
        self.gridCellShadowColor = [UIColor colorWithWhite:0 alpha:0.15];
        
        self.gridStatusViewNudgeColor = [UIColor an_colorWithHexString:@"#F58A31"];
        self.gridStatusViewBlackColor = [UIColor an_colorWithHexString:@"#1C1C19"];
        self.gridStatusViewRecordColor = [UIColor an_colorWithHexString:@"#DA0D19"];
        self.gridStatusViewThumbnailDefaultColor = [UIColor an_colorWithHexString:@"#343434"];
        self.gridStatusViewThumnailZColor = [UIColor an_colorWithHexString:@"#625F58"];
        
        self.menuTintColor = [UIColor an_colorWithHexString:@"#4E4D42"];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance
{
    [self _setupNavigationBar];
    [self _setupNavigationButtons];
}

- (void)_setupNavigationBar
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage an_imageWithColor:[UIColor an_colorWithHexString:@"1B1B19"]]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    NSDictionary* titleAttributes = @{NSForegroundColorAttributeName : self.navBarFontColor,
                                      NSFontAttributeName            : [UIFont an_regularFontWithSize:17],
                                      NSKernAttributeName            : @(2.0)};
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
}

- (void)_setupNavigationButtons
{
    [self _addNavItemWithName:@"navbar_btn_back" type:ANBarButtonTypeBack];
    [self _addNavItemWithName:@"navbar_btn_close" type:ANBarButtonTypeClose];
    [self _addNavItemWithName:@"navbar_btn_done" type:ANBarButtonTypeDone];
    
    [self _addNavItemWithName:@"navbar_btn_add" type:ANBarButtonTypeAdd];
    [self _addNavItemWithName:@"navbar_btn_edit" type:ANBarButtonTypeEdit];
    [self _addNavItemWithName:@"navbar_btn_more" type:ANBarButtonTypeMore];
}

- (void)_addNavItemWithName:(NSString*)name type:(ANBarButtonType)type
{
    UIImage* icon = [UIImage imageWithPDFNamed:name atHeight:kNavigationBarIconHeight];
    [UIBarButtonItem an_addImage:[icon an_imageByTintingWithColor:[UIColor whiteColor]] forType:type];
}

- (id<ANColorThemeButtonInterface>)editFriendsTheme
{
    if (!_editFriendsTheme)
    {
        _editFriendsTheme = [ANColorThemeButton new];
        
        _editFriendsTheme.normalStateBackground = [UIColor clearColor];
        _editFriendsTheme.selectedStateBackground = [UIColor clearColor];
        _editFriendsTheme.disabledStateBackground = [UIColor clearColor];
        _editFriendsTheme.normalStateFontColor = self.baseColor;
        _editFriendsTheme.font = [UIFont an_regularFontWithSize:18];
    }
    return _editFriendsTheme;
}

@end
