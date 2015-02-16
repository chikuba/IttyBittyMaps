//
//  JENLocation.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENLocation.h"

@implementation JENLocation

@synthesize coordinate;
@synthesize title;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
	
    if (self) {
        coordinate = coord;
		title = @"temp";
    }
    return self;
}

- (double) distanceToLocation:(JENLocation*)otherLocation {
	
	if([otherLocation isEqual:[NSNull null]])
	{
		
	}
	   
	
	CLLocation *start = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude
												   longitude:self.coordinate.longitude];
	
	CLLocation *finish = [[CLLocation alloc] initWithLatitude:otherLocation.coordinate.latitude
													longitude:otherLocation.coordinate.longitude];
	
	CLLocationDistance meters = [start distanceFromLocation:finish];
	
	return meters; 
}

@end
