//
//  JENTour.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENTour.h"
#import "JENLocation.h"

#include <stdlib.h>

@interface JENTour () {
	
	double distance;
}

@end

@implementation JENTour

-(id)initWithLocations:(NSMutableArray*)locations {
	self = [super init];
	
    if (self) {
        self.locations = locations;
		distance = 0.0;
    }
    return self;
}

-(id)initAsCrossoverOfTour1:(JENTour*)parent1 andTour2:(JENTour*)parent2 {
	self = [super init];
	
    if (self) {
        self.locations = [[NSMutableArray alloc] initWithCapacity:[parent1.locations count]];
		distance = 0.0;

		int startPos = arc4random_uniform([parent1.locations count]);
		int endPos = arc4random_uniform([parent1.locations count]);
		
		for (int i = 0; i < [parent1.locations count]; i++) {
			
			self.locations[i] = [NSNull null];
			
			if ((startPos < endPos) && (i > startPos) && (i < endPos)) {
				self.locations[i] = parent1.locations[i];
			}
			else if (startPos > endPos) {
				if (!((i < startPos) && (i > endPos))) {
					self.locations[i] = parent1.locations[i];
				}
			}
		}
		
		for (int i = 0; i < [parent2.locations count]; i++) {
			
			if (![self.locations containsObject:parent2.locations[i]]) {
				
				for (int j = 0; j < [parent1.locations count]; j++) {

					if ([self.locations[j] isEqual:[NSNull null]]) {
						self.locations[j] =  parent2.locations[i];
						break;
					}
				}
			}
		}
	}
    return self;
}

-(void)shuffle {
	
	NSUInteger count = [self.locations count];
	
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
		
        [self.locations exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

-(void)mutate {
	
	for(int i = 0; i < [self.locations count]; i++) {
		
		if(arc4random_uniform(1000) < 2) { // fix
						
			[self.locations exchangeObjectAtIndex:arc4random_uniform((u_int32_t )[self.locations count])
								withObjectAtIndex:i];
		}
	}
}

-(double)getLenghtOfTour {
	
	if(distance > 0.0) return distance;
	
	JENLocation* previousLocation = nil;
	distance = 0.0;
	
	for (JENLocation* location in self.locations) {
		
		distance += [previousLocation distanceToLocation:location];
		
		previousLocation = location;
	}
	
	JENLocation* start = [self.locations firstObject];
	JENLocation* finish = [self.locations lastObject];
	
	distance += [start distanceToLocation:finish];
	
	return distance;
}


@end
