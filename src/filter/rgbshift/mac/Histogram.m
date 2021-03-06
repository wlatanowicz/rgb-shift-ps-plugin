//
//  Histogram.m
//
//
//  Created by Wiktor Latanowicz on 29/09/16.
//
//

#import "Histogram.h"

@implementation Histogram

- (id) init
{

	histogramData = [[NSArray alloc] initWithObjects:
	[self emptyColorArray],
	[self emptyColorArray],
	[self emptyColorArray],
	nil];

	[self loadData];
	return self;
}

-(NSMutableArray*)emptyColorArray
{
	NSMutableArray *array = [NSMutableArray array];
	for ( int i=0; i<256; i++){
		[array addObject:[NSNumber numberWithInt:0]];
	}
	return array;
}

-(NSArray*)data
{
	return histogramData;
}

-(void) loadDataRectange: (void*) data
	rowBytes: (int32) dataRowBytes
	mask: (void*) mask
	rowBytes: (int32) maskRowBytes
	tile: (VRect) tileRect
	color: (int16) color
	depth: (int32) depth
{

	uint8* pixel = (uint8*)data;
	uint16* bigPixel = (uint16*)data;
	float* fPixel = (float*)data;
	uint8* maskPixel = (uint8*)mask;

	int32 rectHeight = tileRect.bottom - tileRect.top;
	int32 rectWidth = tileRect.right - tileRect.left;

	for(int32 pixelY = 0; pixelY < rectHeight; pixelY++)
	{
		for(int32 pixelX = 0; pixelX < rectWidth; pixelX++)
		{

			bool leaveItAlone = false;
			if (maskPixel != NULL && !(*maskPixel) && !gParams->ignoreSelection)
				leaveItAlone = true;

			if (!leaveItAlone)
			{
				int16 colorValue;

				if (depth == 32){
					colorValue = (*fPixel * 255);
				}
				else if (depth == 16){
					colorValue = *bigPixel / 0xff;
				}
				else {
					colorValue = *pixel;
				}
				
				NSNumber *number = [[histogramData objectAtIndex:color] objectAtIndex: colorValue];
				number = [NSNumber numberWithDouble:([number doubleValue]+1)];
				[[histogramData objectAtIndex:color] setObject:number atIndex:colorValue];

			}
			pixel++;
			bigPixel++;
			fPixel++;
			if (maskPixel != NULL)
				maskPixel++;
		}
		pixel += (dataRowBytes - rectWidth);
		bigPixel += (dataRowBytes / 2 - rectWidth);
		fPixel += (dataRowBytes / 4 - rectWidth);
		if (maskPixel != NULL)
			maskPixel += (maskRowBytes - rectWidth);
	}

}

-(void) loadData
{
	NSLog(@"IM HERE :-)");

	// make the random number generated trully random
	srand((unsigned)time(NULL));

	int32 tileHeight = gFilterRecord->outTileHeight;
	int32 tileWidth = gFilterRecord->outTileWidth;

	if (tileWidth == 0 || tileHeight == 0)
	{
		*gResult = filterBadParameters;
		return;
	}

	VRect filterRect = GetFilterRect();
	int32 rectWidth = filterRect.right - filterRect.left;
	int32 rectHeight = filterRect.bottom - filterRect.top;

	// round up to the nearest horizontal and vertical tile count
	int32 tilesVert = (tileHeight - 1 + rectHeight) / tileHeight;
	int32 tilesHoriz = (tileWidth - 1 + rectWidth) / tileWidth;

	// Fixed numbers are 16.16 values
	// the first 16 bits represent the whole number
	// the last 16 bits represent the fraction
	gFilterRecord->inputRate = (int32)1 << 16;
	gFilterRecord->maskRate = (int32)1 << 16;

	// variables for the progress bar, our plug in is so fast
	// we probably don't need these
	int32 progressTotal = tilesVert * tilesHoriz;
	int32 progressDone = 0;

	int16 origOutLoPlane = gFilterRecord->outLoPlane;
	int16 origOutHiPlane = gFilterRecord->outHiPlane;
	int16 origInLoPlane = gFilterRecord->inLoPlane;
	int16 origInHiPlane = gFilterRecord->inHiPlane;

	VRect origOutRect = GetOutRect();
	VRect origInRect = GetInRect();
	VRect origMaskRect = GetMaskRect();

	// loop through each tile makeing sure we don't go over the bounds
	// of the rectHeight or rectWidth
	for (int32 vertTile = 0; vertTile < tilesVert; vertTile++)
	{
		for (int32 horizTile = 0; horizTile < tilesHoriz; horizTile++)
		{
			filterRect = GetFilterRect();
			VRect inRect = GetInRect();

			inRect.top = vertTile * tileHeight + filterRect.top;
			inRect.left = horizTile * tileWidth + filterRect.left;
			inRect.bottom = inRect.top + tileHeight;
			inRect.right = inRect.left + tileWidth;

			if (inRect.bottom > rectHeight)
				inRect.bottom = rectHeight;
			if (inRect.right > rectWidth)
				inRect.right = rectWidth;

			SetInRect(inRect);

			// duplicate what's in the inData with the outData
			SetOutRect(inRect);

			// get the maskRect if the user has given us a selection
			if (gFilterRecord->haveMask)
			{
				SetMaskRect(inRect);
			}

			for (int16 plane = 0; plane < gFilterRecord->planes; plane++)
			{
				// we want one plane at a time, small memory foot print is good
				gFilterRecord->outLoPlane = gFilterRecord->inLoPlane = plane;
				gFilterRecord->outHiPlane = gFilterRecord->inHiPlane = plane;

				// update the gFilterRecord with our latest request
				*gResult = gFilterRecord->advanceState(); //@TODO @TODEL //removal of this line crashes PS...
				if (*gResult != noErr) return;


				[self loadDataRectange:gFilterRecord->outData rowBytes:gFilterRecord->outRowBytes mask:gFilterRecord->maskData
				 rowBytes:gFilterRecord->maskRowBytes tile:GetOutRect() color:plane depth:gFilterRecord->depth];

			}

			// uh, update the progress bar

			// see if the user is impatient or didn't mean to do that
			if (gFilterRecord->abortProc())
			{
				*gResult = userCanceledErr;
				return;
			}
		}
	}

	SetMaskRect(origMaskRect);
	SetInRect(origInRect);
	SetOutRect(origOutRect);

	gFilterRecord->outLoPlane = origOutLoPlane;
	gFilterRecord->outHiPlane = origOutHiPlane;
	gFilterRecord->inLoPlane = origInLoPlane;
	gFilterRecord->inHiPlane = origInHiPlane;

}


-(int)peak:(int)color
{
	NSArray *colorArray = [histogramData objectAtIndex:color];
	double peakValue = 0;
	int peakPosition = 0;

	for (int i=1; i<[colorArray count]-1; i++){
		int v = [[colorArray objectAtIndex:i] doubleValue];
		if ( v > peakValue ){
			peakValue = v;
			peakPosition = i;
		}
	}
	return peakPosition;
}

-(int)massCenter:(int)color
{
	NSArray *colorArray = [histogramData objectAtIndex:color];
	
	double totalMass = 0;

	for (int i=1; i<[colorArray count]-1; i++){
		totalMass += ( [[colorArray objectAtIndex:i] doubleValue] + 1 ); 
	}
	
	double halfMass = totalMass / 2.0;
	
	totalMass = 0;
	
	for (int i=1; i<[colorArray count]-1; i++){
		totalMass += ( [[colorArray objectAtIndex:i] doubleValue] + 1 ); 
		
		if ( totalMass >= halfMass ){
			return i;
		}
	}
	
	return [colorArray count] - 1;
}

-(int)center:(int)color at:(double)percent
{
	NSArray *colorArray = [histogramData objectAtIndex:color];
	
	double peakValue = 0;

	for (int i=1; i<[colorArray count]-1; i++){
		double v = [[colorArray objectAtIndex:i] doubleValue];
		if ( v > peakValue ){
			peakValue = v;
		}
	}
	
	double triggerValue = peakValue * percent / 100.0;

	int start = 0;
	int end = [colorArray count]-2;
	
	for (int i=1; i<[colorArray count]-1; i++){
		double v = [[colorArray objectAtIndex:i] doubleValue];
		if (v >= triggerValue){
			start = i;
			break;
		}
	}
	
	for (int i=[colorArray count]-2; i >= 1; i--){
		double v = [[colorArray objectAtIndex:i] doubleValue];
		if (v >= triggerValue){
			end = i;
			break;
		}
	}
	
	return ( end + start ) / 2;
}

@end
