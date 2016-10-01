#import <Cocoa/Cocoa.h>
#include "Dissolve.h"
#include "Histogram.h"
#include "HistogramView.h"

OSStatus initializeCocoaDissolve(void);
OSStatus orderWindowFrontDissolve(void);

@interface DissolveController : NSObject 
{
    id dissolveWindow;

	id proxyPreview;
	
	IBOutlet id redOffset;
	IBOutlet id greenOffset;
	IBOutlet id blueOffset;
	
	IBOutlet NSTextField * redLabel;
	IBOutlet NSTextField * greenLabel;
	IBOutlet NSTextField * blueLabel;
	
	IBOutlet HistogramView* histogramView;
	Histogram * histogram;
	
}
- (void) updateProxy;
- (void) updateCursor;
- (int) showWindow;
+ (DissolveController *) dissolveController;
@end

