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
	
	double _distance;
}

@end

@implementation JENTour

-(id)initWithLocations:(NSMutableArray*)locations {
	
	self = [super init];
	
    if (self) {
		
        self.locations = locations;
		_distance = 0.0;
    }
	
    return self;
}

-(id)initAsCrossoverOfTour1:(JENTour*)parent1 andTour2:(JENTour*)parent2 {
	
	NSAssert(([parent1.locations count] == [parent2.locations count]),
			 @"To be able to mate two lists, they need to be of equal size, ",
			 @"otherwise me might end up with empty slots or duplicates. ");
	
	self = [super init];
	
    if (self) {
		
        self.locations = [[NSMutableArray alloc] initWithCapacity:[parent1.locations count]];
		_distance = 0.0;

		int startPos = arc4random_uniform([parent1.locations count]);
		int endPos = arc4random_uniform([parent1.locations count]);
		
		// add one or two chunks from the first list to our list
		for (int i = 0; i < [parent1.locations count]; i++) {
			
			self.locations[i] = [NSNull null];
			
			if (((startPos < endPos) && (i > startPos) && (i < endPos))
				|| ((startPos > endPos) && !((i < startPos) && (i > endPos)))) {
				
				self.locations[i] = parent1.locations[i];
			}
		}
		
		// then add the locations we dont have until the list is complete
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

- (void)shuffle {
	
	NSUInteger count = [self.locations count];
	
    for (NSUInteger i = 0; i < count; ++i) {
		
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
		
        [self.locations exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

- (void)mutate {
	
	for(int i = 0; i < [self.locations count]; i++) {
		
		if(arc4random_uniform(1000) < 2) { // fix
						
			[self.locations exchangeObjectAtIndex:arc4random_uniform((u_int32_t )[self.locations count])
								withObjectAtIndex:i];
		}
	}
}

- (double)getDistance {
	
	if(_distance > 0.0) return _distance;
	
	JENLocation* previousLocation = nil;
	_distance = 0.0;
	
	for (JENLocation* location in self.locations) {
		
		_distance += [previousLocation distanceToLocation:location];
		
		previousLocation = location;
	}
	
	JENLocation* start = [self.locations firstObject];
	JENLocation* finish = [self.locations lastObject];
	
	_distance += [start distanceToLocation:finish];
	
	return _distance;
}

@end
