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
	
	int popluationSize;
	NSMutableArray *locations;
	NSMutableArray *tours;
}

@end

@implementation JENTourPlanner 

-(id)initWithTourLocations:(NSMutableArray*)_locations Population:(int)_populationSize {

	self = [super init];
	
    if (self) {
        popluationSize = _populationSize;
		locations = _locations;
		tours = [[NSMutableArray alloc] initWithCapacity:popluationSize];
		
		for(int i = 0; i < popluationSize; i++) {
			
			tours[i] = [[JENTour alloc] initWithLocations:locations];
			
			[tours[i] shuffle];
		}
    }
    return self;
}

-(JENTour*)getShortestTour {
	
	return [self getShortestTour:tours];
}

-(JENTour*)getShortestTour:(NSMutableArray*)_tours {
	
	JENTour* shortestTour = [_tours firstObject];
	
	for (JENTour* tour in _tours) {
				
		if([tour getLenghtOfTour] < [shortestTour getLenghtOfTour]) {
			shortestTour = tour;
		}
	}
	
	return shortestTour;
}

-(void)evolveTours {
	
	for (int i = 0; i < 100; i++) {

		NSMutableArray *newTourPopluation = [[NSMutableArray alloc] initWithCapacity:popluationSize];
		
		newTourPopluation[0] = [self getShortestTour:tours];
		
		for (int i = 1; i < popluationSize; i++) {
			
			JENTour* parent1 = [self getRandomTour];
			JENTour* parent2 = [self getRandomTour];
			
			JENTour* child = [[JENTour alloc] initAsCrossoverOfTour1:parent1
															andTour2:parent2];
			
			newTourPopluation[i] = child;
		}
		
		for (JENTour* tour in newTourPopluation) {
			[tour mutate];
		}
		
		tours = newTourPopluation;
	}
}

-(JENTour*)getRandomTour {
	
	NSMutableArray* tourPool = [[NSMutableArray alloc] initWithCapacity:7];
	
	for (int i = 0; i < 7; i++) {
		tourPool[i] = tours[arc4random_uniform([tours count])];
	}
	
	return [self getShortestTour:tourPool];
}

@end
