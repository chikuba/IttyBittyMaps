//
//  JENTour.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JENTour : NSObject 

@property (strong, nonatomic) NSArray *locations;

- (id)initWithLocations:(NSArray*)locations;
- (id)initAsCrossoverOfTour1:(JENTour*)parent1 andTour2:(JENTour*)parent2;

- (void)shuffle;
- (void)mutate;

- (double)distance;

@end
