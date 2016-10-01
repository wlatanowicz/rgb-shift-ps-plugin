#import "DissolveController.h"
#import "DissolveProxyView.h"

DissolveController *gDissolveController = NULL;

@implementation DissolveController

+ (DissolveController *) dissolveController 
{
    return gDissolveController;
}


- (id) init 
{
    self = [super init];
    
    NSBundle * plugin = [NSBundle bundleForClass:[self class]];

    if (![plugin loadNibNamed:@"DissolveDialog"
                 owner:self
                 topLevelObjects:nil])
	{
        NSLog(@"Dissolve failed to load DissolveDialog xib");
    }
    
	gDissolveController = self;


	[redOffset setIntValue:gParams->redOffset];
	[greenOffset setIntValue:gParams->greenOffset];
	[blueOffset setIntValue:gParams->blueOffset];
	
	[self offsetChanged:nil];
	
	NSLog(@"Dissolve Trying to set initial disposition");

	NSLog(@"Dissolve Trying to set setNeedsDisplay");

	[proxyPreview setNeedsDisplay:YES];

	NSLog(@"Dissolve Done with init");
	
	histogram = [[Histogram alloc] init];
	
	[histogramView setHistogram: histogram];

    return self;
}

- (int) showWindow 
{
    [dissolveWindow makeKeyAndOrderFront:nil];
	int b = [[NSApplication sharedApplication] runModalForWindow:dissolveWindow];
	[dissolveWindow orderOut:self];
	return b;
}



- (IBAction) okPressed: (id) sender 
{
	[NSApp stopModalWithCode:1];
	NSLog(@"Dissolve after nsapp stopmodal");
}

- (IBAction) cancelPressed: (id) sender 
{
	NSLog(@"Dissolve cancel pressed");
	[NSApp stopModalWithCode:0];
	NSLog(@"Dissolve after nsapp abortmodal");
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
	
	[gDissolveController updateProxy];
	[histogramView setNeedsDisplay:YES];
}

- (void) updateProxy 
{
	//CopyColor(gData->color, gData->colorArray[gParams->disposition]);
	[proxyPreview setNeedsDisplay:YES];
}

- (void) updateCursor
{
	NSLog(@"Dissolve Trying to updateCursor");
	sPSUIHooks->SetCursor(kPICursorArrow);
	NSLog(@"Dissolve Seemed to updateCursor");
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
OSStatus initializeCocoaDissolve(void) 
{
	[[DissolveController alloc] init];
    return noErr;
}

OSStatus orderWindowFrontDissolve(void) 
{
    int okPressed = [[DissolveController dissolveController] showWindow];
    return okPressed;
}

// end DissolveController.m
