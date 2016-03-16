//
//  <%prefix%><%module%>Wireframe.m
//  <%project%>
//

#import "<%prefix%><%module%>Wireframe.h"
#import "<%prefix%><%module%>Interactor.h"
#import "<%prefix%><%module%>VC.h"
#import "<%prefix%><%module%>Presenter.h"
#import "<%prefix%><%module%>.h"

@interface <%prefix%><%module%>Wireframe ()

@property (nonatomic, weak) <%prefix%><%module%>Presenter* presenter;
@property (nonatomic, weak) <%prefix%><%module%>VC* <%moduleLower%>Controller;
@property (nonatomic, weak) UINavigationController* presentedController;

@end

@implementation <%prefix%><%module%>Wireframe

- (void)present<%module%>ControllerFromNavigationController:(UINavigationController *)nc
{
    <%prefix%><%module%>VC* <%moduleLower%>Controller = [<%prefix%><%module%>VC new];
    <%prefix%><%module%>Interactor* interactor = [<%prefix%><%module%>Interactor new];
    <%prefix%><%module%>Presenter* presenter = [<%prefix%><%module%>Presenter new];
    
    interactor.output = presenter;
    
    <%moduleLower%>Controller.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:<%moduleLower%>Controller];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:<%moduleLower%>Controller animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.<%moduleLower%>Controller = <%moduleLower%>Controller;
}

- (void)dismiss<%module%>Controller
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end
