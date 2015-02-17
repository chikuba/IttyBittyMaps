//
//  JENMapViewController.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENMapViewController.h"
#import <FlickrKit.h>
#import "JENLocation.h"
#import "JENTour.h"
#import "JENTourPlanner.h"

@implementation JENMapViewController

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[FlickrKit sharedFlickrKit] call:@"flickr.photos.search"
								 args:@{@"accuracy": @"11",
										@"has_geo": @"1",
										@"lat": @"-37.796014",
										@"lon": @"144.944347",
										@"per_page": @"100",
										@"extras":@"geo,url_t,url_o,url_m"}
						  maxCacheAge:FKDUMaxAgeOneHour
						   completion:^(NSDictionary *response, NSError *error) {
							   			 
		   if (response) {
			   		
			   dispatch_async(dispatch_get_global_queue(0,0), ^ {
				   
				   NSMutableArray* locations = [self parseLocations:[[response objectForKey:@"photos"] objectForKey:@"photo"]];
				   
				   dispatch_async(dispatch_get_main_queue(), ^{
					   [self addLocationsToMap:locations];
				   });
				   
				   JENTour* tour = [self planTour:locations];
				   
				   dispatch_async(dispatch_get_main_queue(), ^{
					   [self drawTour:tour];
				   });
			   });
			   			   
		   } else {
			   // show the error
		   }
	}];
}

-(void)viewDidAppear:(BOOL)animated {
	
	CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = -37.796014;
    zoomLocation.longitude= 144.944347;
	
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10000, 10000);
	
    [self.mapView setRegion:viewRegion animated:YES];
}

-(NSMutableArray*)parseLocations:(NSDictionary*)photos {
	
	NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:[photos count]];

	for (NSDictionary *photo in photos) {

		CLLocationCoordinate2D coordinate;

		coordinate.latitude = [[photo objectForKey:@"latitude"] doubleValue];
		coordinate.longitude = [[photo objectForKey:@"longitude"] doubleValue];

		bool groupedWithOtherLocation = false;

		for (JENLocation* location in locations) {

			if([location shouldIncludeCoordinate:coordinate]) {

				[location addImageUrl:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75
															   fromPhotoDictionary:photo]];
				groupedWithOtherLocation = true;
				break;
			}
		}

		if(groupedWithOtherLocation) continue;
		
		JENLocation *location;
		
		if([locations count] == 0) {
			
			location = [[JENLocation alloc] initWithCoordinate:coordinate]; // the hotell
			
		} else location = [[JENLocation alloc] initWithCoordinate:coordinate
															 title:[photo objectForKey:@"title"]];

		[location addImageUrl:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75
													   fromPhotoDictionary:photo]];

		[locations addObject:location];
	}

	return locations;

}

-(void)addLocationsToMap:(NSMutableArray*)locations {
	
	for (JENLocation* location in locations) {
		
		[self.mapView addAnnotation:location];
	}
}

-(JENTour*)planTour:(NSMutableArray*)locations {
	
	JENTourPlanner* tourplanner = [[JENTourPlanner alloc] initWithTourLocations:locations
																 populationSize:200];
	[tourplanner replanTours];
	
	return [tourplanner getShortestTour];
}

-(void)drawTour:(JENTour*)tour {
	
    CLLocationCoordinate2D *pointsCoordinate = (CLLocationCoordinate2D *)
	malloc(sizeof(CLLocationCoordinate2D) * [tour.locations count] + 1);
	
	for (int i = 0; i < [tour.locations count]; ++i) {
		pointsCoordinate[i] = [tour.locations[i] coordinate];
	}

	pointsCoordinate[[tour.locations count]] = [tour.locations[0] coordinate];
	
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:pointsCoordinate
														 count:[tour.locations count] + 1];
    free(pointsCoordinate);
	
    [self.mapView addOverlay:polyline];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	
	MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:5/255. green:5/255. blue:5/255. alpha:1.0];
    polylineView.lineWidth = 2;
	
    return polylineView;
}

- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
    static NSString *annotaionIdentifier = @"annotationIdentifier";
	
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier];
	
    if(pinView == nil) {
		
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
												  reuseIdentifier:annotaionIdentifier];
        
        pinView.rightCalloutAccessoryView = nil;
        pinView.animatesDrop = true;
        pinView.canShowCallout = true;
		pinView.draggable = false;
        pinView.calloutOffset = CGPointMake(-5, 5);
		
		if([annotation isKindOfClass:[JENLocation class]]) {
			
			pinView.pinColor = ((JENLocation*)annotation).isHotel ? MKPinAnnotationColorPurple : MKPinAnnotationColorRed;
		}

    }
	
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	if([view.annotation isKindOfClass:[JENLocation class]]) {
	
		UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:((JENLocation*)view.annotation).imageUrls[0]]];
		
		UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
		view.leftCalloutAccessoryView = imgView;
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	
	for (MKAnnotationView *view in views) {

		if([view.annotation isKindOfClass:[JENLocation class]]) {
			
			if(((JENLocation*)view.annotation).isHotel) {
				[mapView selectAnnotation:view.annotation animated:YES];

			}
		}
	}
}

@end
