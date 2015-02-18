//
//  JENMapViewController.m
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import "JENMapViewController.h"
#import "JENPhotoLocation.h"
#import "JENTour.h"
#import "JENTourPlanner.h"
#import <FlickrKit.h>

@implementation JENMapViewController

#define NumberOfPhotosFromFlickr @"100"

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Tour planning

- (void)fetchAndDrawPhotoTourForLocationAsync:(CLLocationCoordinate2D)coordinate {
	
	[[FlickrKit sharedFlickrKit]
	 call:@"flickr.photos.search"
					
	 args:@{@"accuracy": @"11",
			@"has_geo": @"1",
			@"lat": [NSString stringWithFormat:@"%f", coordinate.latitude],
			@"lon": [NSString stringWithFormat:@"%f", coordinate.longitude],
			@"per_page": NumberOfPhotosFromFlickr,
			@"extras":@"geo,url_t,url_o,url_m"}
	 maxCacheAge:FKDUMaxAgeOneHour
	 completion:^(NSDictionary *response, NSError *error) {
							   
	   if (response) {
		   
		   dispatch_async(dispatch_get_global_queue(0,0), ^ {
			   
			   NSMutableArray* photoLocations = [self parseLocations:[[response objectForKey:@"photos"] objectForKey:@"photo"]];
			   
			   dispatch_async(dispatch_get_main_queue(), ^{
				   [self addLocationsToMap:[[NSArray alloc] initWithArray:photoLocations]];
			   });
			   
			   JENTour* tour = [self planTour:photoLocations];
			   
			   dispatch_async(dispatch_get_main_queue(), ^{
				   [self drawTourOnMap:tour];
			   });
		   });
		   
	   } else {
		   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to fetch photos"
														   message:error.localizedDescription
														  delegate:self
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		   [alert show];
	   }
   }];
}

-(NSMutableArray*)parseLocations:(NSDictionary*)photos {
	
	NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:[photos count]];

	for (NSDictionary *photo in photos) {

		CLLocationCoordinate2D coordinate;

		coordinate.latitude = [[photo objectForKey:@"latitude"] doubleValue];
		coordinate.longitude = [[photo objectForKey:@"longitude"] doubleValue];

		bool groupedWithOtherLocation = false;

		for (JENPhotoLocation* location in locations) {

			if([location shouldIncludeCoordinate:coordinate]) {

				[location addImageUrl:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75
															   fromPhotoDictionary:photo]];
				groupedWithOtherLocation = true;
				break;
			}
		}

		if(groupedWithOtherLocation) continue;
		
		JENPhotoLocation *location;
		
		if([locations count] == 0) {
			
			location = [[JENPhotoLocation alloc] initWithCoordinate:coordinate]; // the hotell
			
		} else location = [[JENPhotoLocation alloc] initWithCoordinate:coordinate
															 title:[photo objectForKey:@"title"]];

		[location addImageUrl:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75
													   fromPhotoDictionary:photo]];

		[locations addObject:location];
	}

	return locations;

}

-(void)addLocationsToMap:(NSArray*)photoLocations {
	
	for (JENPhotoLocation* photoLocation in photoLocations) {
		
		[self.mapView addAnnotation:photoLocation];
	}
}

-(JENTour*)planTour:(NSMutableArray*)photoLocations {
	
	JENTourPlanner* tourplanner = [[JENTourPlanner alloc] initWithTourLocations:photoLocations
																 populationSize:200];
	[tourplanner replanTours];
	
	return [tourplanner getShortestTour];
}

-(void)drawTourOnMap:(JENTour*)tour {
	
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
    }
	
	if([annotation isKindOfClass:[JENPhotoLocation class]]) {
		
		pinView.pinColor = ((JENPhotoLocation*)annotation).isHotel ?
		MKPinAnnotationColorPurple : MKPinAnnotationColorRed;
	}
	
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	if([view.annotation isKindOfClass:[JENPhotoLocation class]]) {
	
		UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:((JENPhotoLocation*)view.annotation).imageUrls[0]]];
		
		UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
		view.leftCalloutAccessoryView = imgView;
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	
	for (MKAnnotationView *view in views) {

		if([view.annotation isKindOfClass:[JENPhotoLocation class]]) {
			
			if(((JENPhotoLocation*)view.annotation).isHotel) {
				
				[mapView selectAnnotation:view.annotation
								 animated:true];
			}
		}
	}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000);
	
    [self.mapView setRegion:viewRegion
				   animated:true];
	
	[self fetchAndDrawPhotoTourForLocationAsync:userLocation.coordinate];
}

@end
