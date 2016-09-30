//
//  HistogramView.m
//  dissolve
//
//  Created by Wiktor Latanowicz on 29/09/16.
//
//

#import "HistogramView.h"

@implementation HistogramView

-(void) setHistogram: (Histogram*)h
{
	histogram = h;
}

-(void) setRedOffset: (float)v
{
	redOffset = v;
}

-(void) setGreenOffset: (float)v
{
	greenOffset = v;
}

-(void) setBlueOffset: (float)v
{
	blueOffset = v;
}

-(NSColor*)colorForLine:(int)num
{
    
    switch ( num % 3 ){
        case 0: return [NSColor redColor];
        case 1: return [NSColor greenColor];
        case 2: return [NSColor blueColor];
		default: return [NSColor blackColor];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {


    [super drawRect:dirtyRect];
	
	NSArray *dataSources = [histogram data];
    
    if ( dataSources == nil ) return;
	
	double minX = 0;
	double minY = 0;
	
	double maxX = [[dataSources objectAtIndex:0] count];
	double maxY = 0;
	
    for ( int l=0; l<[dataSources count]; l++ ) {
        NSArray *line = [dataSources objectAtIndex:l];
        for ( int x=0; x<[line count]; x++ ){
			double v = [[line objectAtIndex:x] doubleValue];
			maxY = v > maxY
				? v
				: maxY;
		}
	}
    
    double scaleX = (double)([self bounds].size.width / ( maxX - minX ) );
    double scaleY = (double)([self bounds].size.height / ( maxY - minY ) );
    
    [[NSColor whiteColor] set];
    NSRectFill( [self bounds] );
    
    for ( int l=0; l<[dataSources count]; l++ ) {
        
        NSArray *line = [dataSources objectAtIndex:l];
		
		float offset = 0;
		switch (l) {
			case 0:
				offset = redOffset;
				break;
			case 1:
				offset = greenOffset;
				break;
			case 2:
				offset = blueOffset;
				break;
		}
		
		int16 intOffset = - (int16)((offset * 1023.0) / 1000.0 );
        
        if ( [line count] >=2 ){
            NSBezierPath *path = [NSBezierPath bezierPath];
            
            [path setLineWidth:1];
            
            [[self colorForLine:l] set];
            
            for ( int x=0; x<[line count]; x++ ){
                
				int correctedX = x + intOffset;
				
				double v = 0;
				
				if (correctedX >= 0 && correctedX <= 1023){
					v = [[line objectAtIndex:correctedX] doubleValue];
				}
                
                double dx = ( ( x - minX ) * scaleX );
                
                double dy = ( ( v - minY ) * scaleY );
                
                if ( x == 0 ){
                    [path moveToPoint:NSMakePoint( dx, dy )];
                }else{
                    [path lineToPoint:NSMakePoint( dx, dy )];
                }
                
            }
            
            [path stroke];
        }
        
    }    
}

@end
