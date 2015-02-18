//
//  JENLocation.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENPhotoLocation.h"

@implementation JENPhotoLocation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize isHotel = _isHotel;

#define InclusionRadiusInMeters 200

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title {
    
	self = [super init];
	
    if (self) {
		
		self.imageUrls = [[NSMutableArray alloc] init];
		
		_isHotel = false;
        _coordinate = coordinate;
		_title = title;
    }
	
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	
	self = [super init];
	
    if (self) {
		
		self.imageUrls = [[NSMutableArray alloc] init];
		
		_isHotel = true;
        _coordinate = coordinate;
		_title = @"The Hotel";
    }
	
    return self;
}

- (double)distanceToLocation:(JENPhotoLocation*)otherLocation {
	
	return [self distanceFrom:self.coordinate to:otherLocation.coordinate];;
}

- (bool)shouldIncludeCoordinate:(CLLocationCoordinate2D)coordinate {
	
	CLLocationDistance meters = [self distanceFrom:self.coordinate to:coordinate];
	
	return (meters < InclusionRadiusInMeters);
}

- (void)addImageUrl:(NSURL*)imageUrl {
	
	[self.imageUrls addObject:imageUrl];
}

#pragma mark -
#pragma mark Helpers

- (double)distanceFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate {
	
	CLLocation *start = [[CLLocation alloc] initWithLatitude:fromCoordinate.latitude
												   longitude:fromCoordinate.longitude];
	
	CLLocation *finish = [[CLLocation alloc] initWithLatitude:toCoordinate.latitude
													longitude:toCoordinate.longitude];
	
	CLLocationDistance meters = [start distanceFromLocation:finish];
	
	return meters;
}

@end
