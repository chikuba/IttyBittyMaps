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
	
	NSMutableArray *_tours;
}

@end

@implementation JENTourPlanner

#define PopulationSize 100
#define EvolutionCycles 300
#define IsolatedMatingPoolPopulation 7

-(id)initWithTourLocations:(NSArray*)locations {

	self = [super init];
	
    if (self) {
		
		_tours = [[NSMutableArray alloc] initWithCapacity:PopulationSize];
		
		for (int i = 0; i < PopulationSize; i++) {
			
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
	
	NSAssert(PopulationSize > 0, @"The poplulationsize must be atleast 1 or more. ");
	
	NSLog(@"shortest tour before replan: %f", [[self getShortestTour] getDistance]);
		
	for (int i = 0; i < EvolutionCycles; i++) {

		NSMutableArray *newTourPopluation = [[NSMutableArray alloc] initWithCapacity:PopulationSize];
		
		newTourPopluation[0] = [self getShortestTour];
		
		for (int i = 1; i < PopulationSize; i++) {
			
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
	
	NSLog(@"shortest tour after replan: %f", [[self getShortestTour] getDistance]);

}

#pragma mark -
#pragma mark Helpers

-(JENTour*)getRandomTour {
	
	NSMutableArray* tourPool = [[NSMutableArray alloc] initWithCapacity:7];
	
	for (int i = 0; i < IsolatedMatingPoolPopulation; i++) {
		tourPool[i] = _tours[arc4random_uniform([_tours count])];
	}
	
	return [self getShortestOfTours:tourPool];
}

-(JENTour*)getShortestOfTours:(NSArray*)tours {
	
	JENTour* shortestTour = [tours firstObject];
	
	for (JENTour* tour in tours) {
		
		if([tour getDistance] < [shortestTour getDistance]) {
			shortestTour = tour;
		}
	}
	
	return shortestTour;
}

@end
