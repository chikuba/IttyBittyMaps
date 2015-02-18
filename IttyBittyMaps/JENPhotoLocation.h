//
//  JENLocation.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JENPhotoLocation : NSObject<MKAnnotation> {
	
	CLLocationCoordinate2D _coordinate;
	NSString *_title;
	bool _isHotel; 
}

@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (readonly, nonatomic) bool isHotel;

// MKAnnotation
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (double)distanceToLocation:(JENPhotoLocation*)otherLocation;
- (bool)shouldIncludeCoordinate:(CLLocationCoordinate2D)coord;

- (void)addImageUrl:(NSURL*)imageUrl;

@end
