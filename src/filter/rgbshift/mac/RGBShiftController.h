#import <Cocoa/Cocoa.h>
#include "RGBShift.h"
#include "Histogram.h"
#include "HistogramView.h"

OSStatus initializeCocoaRGBShift(void);
OSStatus orderWindowFrontRGBShift(void);

@interface RGBShiftController : NSObject 
{
    id rgbshiftWindow;

	id proxyPreview;
	
	IBOutlet id redOffset;
	IBOutlet id greenOffset;
	IBOutlet id blueOffset;
	
	IBOutlet NSTextField * redLabel;
	IBOutlet NSTextField * greenLabel;
	IBOutlet NSTextField * blueLabel;
	
	IBOutlet NSButton * lockCheckbox;
	
	IBOutlet HistogramView* histogramView;
	Histogram * histogram;
	
}
- (void) updateProxy;
- (void) updateCursor;
- (int) showWindow;
+ (RGBShiftController *) rgbshiftController;
@end

