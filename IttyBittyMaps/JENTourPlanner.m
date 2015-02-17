//
//  JENTourPlanner.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENTourPlanner.h"
#import "JENTour.h"

@interface JENTourPlanner () {
	
	int _popluationSize;
	NSMutableArray *_locations;
	NSMutableArray *_tours;
}

@end

@implementation JENTourPlanner 

-(id)initWithTourLocations:(NSMutableArray*)locations populationSize:(int)populationSize {

	self = [super init];
	
    if (self) {
        _popluationSize = populationSize;
		_locations = locations;
		_tours = [[NSMutableArray alloc] initWithCapacity:_popluationSize];
		
		for(int i = 0; i < _popluationSize; i++) {
			
			_tours[i] = [[JENTour alloc] initWithLocations:locations];
			
			[_tours[i] shuffle];
		}
    }
    return self;
}

-(JENTour*)getShortestTour {
	
	return [self getShortestOfTours:_tours];
}

-(void)replanTours {
	
	for (int i = 0; i < 100; i++) {

		NSMutableArray *newTourPopluation = [[NSMutableArray alloc] initWithCapacity:_popluationSize];
		
		newTourPopluation[0] = [self getShortestTour];
		
		for (int i = 1; i < _popluationSize; i++) {
			
			JENTour* parent1 = [self getRandomTour];
			JENTour* parent2 = [self getRandomTour];
			
			JENTour* child = [[JENTour alloc] initAsCrossoverOfTour1:parent1
															andTour2:parent2];
			
			newTourPopluation[i] = child;
		}
		
		for (JENTour* tour in newTourPopluation) {
			[tour mutate];
		}
		
		_tours = newTourPopluation;
	}
}

#pragma mark -
#pragma mark Helpers

-(JENTour*)getRandomTour {
	
	NSMutableArray* tourPool = [[NSMutableArray alloc] initWithCapacity:7];
	
	for (int i = 0; i < 7; i++) {
		tourPool[i] = _tours[arc4random_uniform([_tours count])];
	}
	
	return [self getShortestOfTours:tourPool];
}

-(JENTour*)getShortestOfTours:(NSMutableArray*)tours {
	
	JENTour* shortestTour = [tours firstObject];
	
	for (JENTour* tour in tours) {
		
		if([tour getDistance] < [shortestTour getDistance]) {
			shortestTour = tour;
		}
	}
	
	return shortestTour;
}

@end
