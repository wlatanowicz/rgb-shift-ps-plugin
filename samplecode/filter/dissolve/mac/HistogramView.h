//
//  HistogramView.h
//  dissolve
//
//  Created by Wiktor Latanowicz on 29/09/16.
//
//

#import <Cocoa/Cocoa.h>
#import "Histogram.h"

@interface HistogramView : NSView {

	Histogram * histogram;
	
	float redOffset;
	float greenOffset;
	float blueOffset;

}

-(void) setHistogram: (Histogram*)h;

-(void) setRedOffset: (float)v;
-(void) setGreenOffset: (float)v;
-(void) setBlueOffset: (float)v;


@end
