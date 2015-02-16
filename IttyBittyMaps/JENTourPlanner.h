//
//  JENTourPlanner.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JENTour;

@interface JENTourPlanner : NSObject

-(id)initWithTourLocations:(NSMutableArray*)_locations Population:(int)_populationSize ;
-(JENTour*)getShortestTour;
-(void)evolveTours;
@end
