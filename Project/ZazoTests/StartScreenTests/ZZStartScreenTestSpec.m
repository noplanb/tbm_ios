//
//  ZZStartScreenTestSpec.m
//  Zazo
//
//  Created by ANODA on 17/08/15.
//  Copyright 2015 ANODA. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "ZZAuthWireframe.h"
#import "ZZAuthVC.h"
#import "KIF.h"


SpecBegin(ZZStartScreenTest)

describe(@"ZZStartScreenTest", ^{
    __block ZZAuthWireframe* wireframe;
    __block ZZAuthVC* vc;
    beforeAll(^{
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        wireframe  = [ZZAuthWireframe new];
        [wireframe presentAuthControllerFromWindow:window];
        
    });
    
    
    context(@"button test", ^{
       beforeEach(^{
       });
        it(@"button tap test", ^{
            
            [tester enterText:@"John" intoViewWithAccessibilityLabel:@"firstName"];
            [tester enterText:@"Doe" intoViewWithAccessibilityLabel:@"lastName"];
            [tester enterText:@"38" intoViewWithAccessibilityLabel:@"phoneCode"];
            [tester enterText:@"0974720070" intoViewWithAccessibilityLabel:@"phoneNumber"];
            [tester tapViewWithAccessibilityLabel:@"SignIn"];
            
            
            [tester waitForTappableViewWithAccessibilityLabel:@"38"];
        });
    });
    
    beforeEach(^{

    });
    
    it(@"", ^{

    });  
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
