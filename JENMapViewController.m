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

#define NumberOfPhotosFromFlickr 100

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark -
#pragma mark Tour planning

- (void)fetchAndDrawPhotoTourForLocationAsync:(CLLocationCoordinate2D)coordinate {
	
	__weak typeof(self) weakSelf = self;
	
	[[FlickrKit sharedFlickrKit]
	 call:@"flickr.photos.search"
	 args:@{@"accuracy": @"11",
			@"has_geo": @"1",
			@"lat": [NSString stringWithFormat:@"%f", coordinate.latitude],
			@"lon": [NSString stringWithFormat:@"%f", coordinate.longitude],
			@"per_page": [NSString stringWithFormat:@"%d", NumberOfPhotosFromFlickr],
			@"extras": @"geo"}
	 maxCacheAge:FKDUMaxAgeNeverCache
	 completion:^(NSDictionary *response, NSError *error) {
							   
	   if (response) {
		   
		   dispatch_async(dispatch_get_global_queue(0,0), ^ {
			   
			   NSArray* photoLocations = [weakSelf parseLocations:[[response objectForKey:@"photos"]
																   objectForKey:@"photo"]];
			   
			   dispatch_async(dispatch_get_main_queue(), ^{
				   
				   [weakSelf.mapView addAnnotations:photoLocations];
			   });
			   
			   JENTour* tour = [weakSelf planTour:photoLocations];
			   
			   dispatch_async(dispatch_get_main_queue(), ^{
				   [weakSelf drawTourOnMap:tour];
			   });
		   });
		   
	   } else {
		   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to fetch photos"
														   message:error.localizedDescription
														  delegate:weakSelf
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		   [alert show];
	   }
   }];
}

-(NSArray*)parseLocations:(NSDictionary*)photos {
	
	NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:[photos count]];

	for (NSDictionary *photo in photos) {

		CLLocationCoordinate2D coordinate;
		coordinate.latitude = [[photo objectForKey:@"latitude"] doubleValue];
		coordinate.longitude = [[photo objectForKey:@"longitude"] doubleValue];
		
		bool groupedWithOtherLocation = false;

		for (JENPhotoLocation* location in locations) {

			if([location shouldIncludeCoordinate:coordinate]) {
				
				groupedWithOtherLocation = true;
				break;
			}
		}

		if(groupedWithOtherLocation) continue;
		
		NSURL *thumbnailUrl = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75
													   fromPhotoDictionary:photo];
		
		
		// we just assume that the first one we add is the hotel. this can really be done in a nicer way
		if([locations count] == 0) {
			
			JENPhotoLocation *theHotel = [[JENPhotoLocation alloc]
										  initWithCoordinate:coordinate
										  thumbnailUrl:thumbnailUrl];
			
			[locations addObject:theHotel];
			
		} else {
			
			JENPhotoLocation *photoLocation = [[JENPhotoLocation alloc]
											   initWithCoordinate:coordinate
											   thumbnailUrl:thumbnailUrl
											   title:[photo objectForKey:@"title"]];
			
			[locations addObject:photoLocation];
		}
	}

	return locations;

}

-(JENTour*)planTour:(NSArray*)photoLocations {
	
	JENTourPlanner* tourplanner = [[JENTourPlanner alloc] initWithTourLocations:photoLocations];
	
	[tourplanner replanTours];
	
	return [tourplanner shortestTour];
}

-(void)drawTourOnMap:(JENTour*)tour {
	
	NSAssert(([tour.locations count] > 2), @"You need 3 or more locations to get a full tour");
	
    CLLocationCoordinate2D *pointsCoordinate
	= (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * [tour.locations count] + 1);
	
	for (int i = 0; i < [tour.locations count]; ++i) {
		pointsCoordinate[i] = [tour.locations[i] coordinate];
	}

	pointsCoordinate[[tour.locations count]] = [[tour.locations firstObject] coordinate];
	
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:pointsCoordinate
														 count:[tour.locations count] + 1];
    free(pointsCoordinate);
	
	[self.mapView addOverlay:polyline];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	
	MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blackColor];
    polylineView.lineWidth = 2;
	
    return polylineView;
}

- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
    static NSString *annotaionIdentifier = @"annotationIdentifier";
	
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)
	[mapView dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier];
	
    if(pinView == nil) {
		
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
												  reuseIdentifier:annotaionIdentifier];
        
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
		
		__weak MKAnnotationView *weakView = view;
				
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
																   
			NSData *data = [NSData dataWithContentsOfURL:((JENPhotoLocation*)weakView.annotation).thumbnailUrl];
			UIImage *image = [UIImage imageWithData:data];
																   
			dispatch_async(dispatch_get_main_queue(), ^ {
				
				UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
				weakView.leftCalloutAccessoryView = imgView;
			});
		});
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
