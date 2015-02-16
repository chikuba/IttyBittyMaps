//
//  JENLocation.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JENLocation : NSObject<MKAnnotation> {
	
	CLLocationCoordinate2D coordinate;
	NSString *title;
	
}

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

// image url

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (double) distanceToLocation:(JENLocation*)otherLocation;

@end
