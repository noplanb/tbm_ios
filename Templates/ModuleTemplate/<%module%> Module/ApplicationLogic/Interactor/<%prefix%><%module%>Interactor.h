//
//  <%prefix%><%module%>Interactor.h
//  <%project%>
//

#import "<%prefix%><%module%>InteractorIO.h"

@interface <%prefix%><%module%>Interactor : NSObject <<%prefix%><%module%>InteractorInput>

@property (nonatomic, weak) id<<%prefix%><%module%>InteractorOutput> output;

@end

