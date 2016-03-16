//
//  <%prefix%><%module%>VC.h
//  <%project%>
//

#import "<%prefix%><%module%>ViewInterface.h"
#import "<%prefix%><%module%>ModuleInterface.h"

@interface <%prefix%><%module%>VC : UIViewController <<%prefix%><%module%>ViewInterface>

@property (nonatomic, strong) id<<%prefix%><%module%>ModuleInterface> eventHandler;

@end
