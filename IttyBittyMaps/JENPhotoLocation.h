//
//  JENLocation.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JENPhotoLocation : NSObject<MKAnnotation>

@property (strong, nonatomic, readonly) NSURL *thumbnailUrl;
@property (readonly, nonatomic) bool isHotel;

// MKAnnotation
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate thumbnailUrl:(NSURL*)url title:(NSString*)title;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate thumbnailUrl:(NSURL*)url;

- (double)distanceToLocation:(JENPhotoLocation*)otherLocation;
- (bool)shouldIncludeCoordinate:(CLLocationCoordinate2D)coord;

@end
