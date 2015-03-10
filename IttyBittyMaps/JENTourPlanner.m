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
	
	NSArray *_tours;
}

@end

@implementation JENTourPlanner

#define PopulationSize 100
#define EvolutionCycles 100
#define IsolatedMatingPoolPopulation 5

- (id)initWithTourLocations:(NSArray*)locations {
	
	self = [super init];
	
	if (self) {
		
		NSMutableArray *tourPopulation = [[NSMutableArray alloc] initWithCapacity:PopulationSize];
		
		for (int i = 0; i < PopulationSize; i++) {
			
			tourPopulation[i] = [[JENTour alloc] initWithLocations:locations];
			
			[tourPopulation[i] shuffle];
		}
		
		_tours = tourPopulation;
	}
	
	return self;
}

- (JENTour*)shortestTour {
	
	return [self shortestOfTours:_tours];
}

- (void)replanTours {
	
	NSAssert(PopulationSize > 0, @"The PoplulationSize must be atleast 1 or more. ");
	
	double tourDistanceBefore = [[self shortestTour] distance];
	
	NSLog(@"Shortest tour before replan: %f", tourDistanceBefore);
	
	for (int i = 0; i < EvolutionCycles; i++) {
		
		NSMutableArray *newTourPopluation = [[NSMutableArray alloc] initWithCapacity:PopulationSize];
		
		newTourPopluation[0] = [self shortestTour];
		
		for (int i = 1; i < PopulationSize; i++) {
			
			JENTour* parent1 = [self randomShortTour];
			JENTour* parent2 = [self randomShortTour];
			
			JENTour* child = [[JENTour alloc] initAsCrossoverOfTour1:parent1
															andTour2:parent2];
			
			newTourPopluation[i] = child;
		}
		
		for (JENTour* tour in newTourPopluation) {
			
			[tour mutate];
		}
		
		_tours = newTourPopluation;
	}
	
	double tourDistanceAfter = [[self shortestTour] distance];
	
	NSLog(@"Shortest tour after replan: %f", tourDistanceAfter);
	NSLog(@"Replaned tour is %.1f%% shorter. ", (tourDistanceAfter / tourDistanceBefore) * 100);
}

#pragma mark -
#pragma mark Helpers

- (JENTour*)randomShortTour {
	
	NSMutableArray* tourPool = [[NSMutableArray alloc] initWithCapacity:IsolatedMatingPoolPopulation];
	
	for (int i = 0; i < IsolatedMatingPoolPopulation; i++) {
		tourPool[i] = _tours[arc4random_uniform([_tours count])];
	}
	
	return [self shortestOfTours:tourPool];
}

- (JENTour*)shortestOfTours:(NSArray*)tours {
	
	NSAssert([tours count] > 0, @"The tour needs to contain atleast 1 location. ");
	
	JENTour* shortestTour = [tours firstObject];
	
	for (JENTour* tour in tours) {
		
		if([tour distance] < [shortestTour distance]) {
			shortestTour = tour;
		}
	}
	
	return shortestTour;
}

@end
