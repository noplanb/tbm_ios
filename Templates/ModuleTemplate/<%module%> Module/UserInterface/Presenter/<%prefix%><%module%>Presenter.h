//
//  <%prefix%><%module%>Presenter.h
//  <%project%>
//

#import "<%prefix%><%module%>InteractorIO.h"
#import "<%prefix%><%module%>Wireframe.h"
#import "<%prefix%><%module%>ViewInterface.h"
#import "<%prefix%><%module%>ModuleDelegate.h"
#import "<%prefix%><%module%>ModuleInterface.h"

@interface <%prefix%><%module%>Presenter : NSObject <<%prefix%><%module%>InteractorOutput, <%prefix%><%module%>ModuleInterface>

@property (nonatomic, strong) id<<%prefix%><%module%>InteractorInput> interactor;
@property (nonatomic, strong) <%prefix%><%module%>Wireframe* wireframe;

@property (nonatomic, weak) UIViewController<<%prefix%><%module%>ViewInterface>* userInterface;
@property (nonatomic, weak) id<<%prefix%><%module%>ModuleDelegate> <%moduleLower%>ModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<<%prefix%><%module%>ViewInterface>*)userInterface;

@end
