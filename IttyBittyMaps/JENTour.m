//
//  JENTour.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENTour.h"
#import "JENPhotoLocation.h"

#include <stdlib.h>

@interface JENTour () {
	
	double _distance;
}

@end

@implementation JENTour

#define MutationRate 2

-(id)initWithLocations:(NSArray*)locations {
	
	self = [super init];
	
    if (self) {
		
        self.locations = [[NSArray alloc] initWithArray:locations]; // copy
		_distance = 0.0;
    }
	
    return self;
}

-(id)initAsCrossoverOfTour1:(JENTour*)parent1 andTour2:(JENTour*)parent2 {
		
	NSAssert(([parent1.locations count] == [parent2.locations count]),
			 @"To be able to 'mate' two lists, they need to be of equal size, ",
			 @"otherwise me might end up with empty slots or duplicates. ");
	
	self = [super init];
	
    if (self) {
		
       NSMutableArray *crossoverLocations = [[NSMutableArray alloc] initWithCapacity:[parent1.locations count]];

		int startPos = arc4random_uniform([parent1.locations count]);
		int endPos = arc4random_uniform([parent1.locations count]);
		
		// add one or two chunks from the first list to our list
		for (int i = 0; i < [parent1.locations count]; i++) {
			
			crossoverLocations[i] = [NSNull null];
			
			if (((startPos < endPos) && (i > startPos) && (i < endPos))
				|| ((startPos > endPos) && !((i < startPos) && (i > endPos)))) {
				
				crossoverLocations[i] = parent1.locations[i];
			}
		}
		
		// then add the locations we dont have until the list is complete
		for (int i = 0; i < [parent2.locations count]; i++) {
			
			if (![crossoverLocations containsObject:parent2.locations[i]]) {
				
				for (int j = 0; j < [parent1.locations count]; j++) {

					if ([crossoverLocations[j] isEqual:[NSNull null]]) {
						
						crossoverLocations[j] =  parent2.locations[i];
						break;
					}
				}
			}
		}
		
		self.locations = crossoverLocations;
		_distance = 0.0;
	}
	
    return self;
}

- (void)shuffle {
	
	NSUInteger count = [self.locations count];
	
	NSMutableArray *shuffledLocations = [[NSMutableArray alloc] initWithArray:self.locations];
	
    for (NSUInteger i = 0; i < count; ++i) {
		
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
		
        [shuffledLocations exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
	
	self.locations = shuffledLocations;
	_distance = 0.0;
}

- (void)mutate {
	
	NSUInteger count = [self.locations count];
	
	NSMutableArray *mutatedLocations = [[NSMutableArray alloc] initWithArray:self.locations];
	
	for(int i = 0; i < count; i++) {
		
		if(arc4random_uniform(100) < MutationRate) {
						
			[mutatedLocations exchangeObjectAtIndex:arc4random_uniform((u_int32_t)count)
								withObjectAtIndex:i];
		}
	}
		
	self.locations = mutatedLocations;
	_distance = 0.0;
}

- (double)distance {
	
	if(_distance > 0.0) return _distance;
	
	NSAssert([self.locations count] > 1,
			 @"We need at least 2 locations to be able to calculate the distance correctly. ");
	
	JENPhotoLocation* previousLocation = nil;
	_distance = 0.0;
	
	for (JENPhotoLocation* location in self.locations) {
		
		_distance += [previousLocation distanceToLocation:location];
		
		previousLocation = location;
	}
	
	JENPhotoLocation* start = [self.locations firstObject];
	JENPhotoLocation* finish = [self.locations lastObject];
	
	_distance += [start distanceToLocation:finish];
	
	return _distance;
}

@end
