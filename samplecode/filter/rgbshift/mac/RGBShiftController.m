#import "RGBShiftController.h"
#import "RGBShiftProxyView.h"

RGBShiftController *gRGBShiftController = NULL;

@implementation RGBShiftController

+ (RGBShiftController *) rgbshiftController 
{
    return gRGBShiftController;
}


- (id) init 
{
    self = [super init];
    
    NSBundle * plugin = [NSBundle bundleForClass:[self class]];

    if (![plugin loadNibNamed:@"RGBShiftDialog"
                 owner:self
                 topLevelObjects:nil])
	{
        NSLog(@"RGBShift failed to load RGBShiftDialog xib");
    }
    
	gRGBShiftController = self;


	[redOffset setIntValue:gParams->redOffset];
	[greenOffset setIntValue:gParams->greenOffset];
	[blueOffset setIntValue:gParams->blueOffset];
	
	[self offsetChanged:nil];
	
	NSLog(@"RGBShift Trying to set initial disposition");

	NSLog(@"RGBShift Trying to set setNeedsDisplay");

	[proxyPreview setNeedsDisplay:YES];

	NSLog(@"RGBShift Done with init");
	
	histogram = [[Histogram alloc] init];
	
	[histogramView setHistogram: histogram];

    return self;
}

- (int) showWindow 
{
    [rgbshiftWindow makeKeyAndOrderFront:nil];
	int b = [[NSApplication sharedApplication] runModalForWindow:rgbshiftWindow];
	[rgbshiftWindow orderOut:self];
	return b;
}



- (IBAction) okPressed: (id) sender 
{
	[NSApp stopModalWithCode:1];
	NSLog(@"RGBShift after nsapp stopmodal");
}

- (IBAction) cancelPressed: (id) sender 
{
	NSLog(@"RGBShift cancel pressed");
	[NSApp stopModalWithCode:0];
	NSLog(@"RGBShift after nsapp abortmodal");
}


- (IBAction) offsetChanged:(id)sender
{
	gParams->redOffset = [redOffset intValue];
	gParams->greenOffset = [greenOffset intValue];
	gParams->blueOffset = [blueOffset intValue];
	
	[histogramView setRedOffset:gParams->redOffset];
	[histogramView setGreenOffset:gParams->greenOffset];
	[histogramView setBlueOffset:gParams->blueOffset];
	
	[redLabel setFloatValue:(float)gParams->redOffset/10.0];
	[greenLabel setFloatValue:(float)gParams->greenOffset/10.0];
	[blueLabel setFloatValue:(float)gParams->blueOffset/10.0];
	
	[gRGBShiftController updateProxy];
	[histogramView setNeedsDisplay:YES];
}

- (void) updateProxy 
{
	//CopyColor(gData->color, gData->colorArray[gParams->disposition]);
	[proxyPreview setNeedsDisplay:YES];
}

- (void) updateCursor
{
	NSLog(@"RGBShift Trying to updateCursor");
	sPSUIHooks->SetCursor(kPICursorArrow);
	NSLog(@"RGBShift Seemed to updateCursor");
}

- (IBAction)zeroPressed:(id)sender
{
	[redOffset setIntValue:0];
	[greenOffset setIntValue:0];
	[blueOffset setIntValue:0];
	[self offsetChanged:nil];
}
	
- (IBAction)peakPressed:(id)sender
{
	int redPeak = 500 - (([histogram peak:0] * 1000)/255);
	int greenPeak = 500 - (([histogram peak:1] * 1000)/255);
	int bluePeak = 500 - (([histogram peak:2] * 1000)/255);
	
	

	[redOffset setIntValue:redPeak];
	[greenOffset setIntValue:greenPeak];
	[blueOffset setIntValue:bluePeak];
	[self offsetChanged:nil];
}
	
@end

/* Carbon entry point and C-callable wrapper functions*/
OSStatus initializeCocoaRGBShift(void) 
{
	[[RGBShiftController alloc] init];
    return noErr;
}

OSStatus orderWindowFrontRGBShift(void) 
{
    int okPressed = [[RGBShiftController rgbshiftController] showWindow];
    return okPressed;
}

// end RGBShiftController.m
