//
//  Histogram.h
//
//
//  Created by Wiktor Latanowicz on 29/09/16.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "RGBShift.h"
#include "PIDefines.h"
#include "PITypes.h"
#include "PIAbout.h"
#include "PIFilter.h"
#include "PIUtilities.h"

#include "RGBShiftUI.h"
#include "RGBShiftScripting.h"
#include "RGBShiftRegistry.h"
#include "FilterBigDocument.h"


@interface Histogram : NSObject {
	NSArray *histogramData;
}

-(NSArray*)data;
-(int)peak:(int)color;

@end
