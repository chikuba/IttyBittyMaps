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

#define METERS_PER_MILE 1609.344

@interface JENMapViewController () {
	
	NSMutableArray *locations;
}

@end

@implementation JENMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	locations = [[NSMutableArray alloc] initWithCapacity:20];
	
	[[FlickrKit sharedFlickrKit] call:@"flickr.photos.search"
								 args:@{@"accuracy": @"11",
										@"has_geo": @"1",
										@"lat": @"-37.796014",
										@"lon": @"144.944347",
										@"per_page": @"100"}
						  maxCacheAge:FKDUMaxAgeOneHour
						   completion:^(NSDictionary *response, NSError *error) {
							   dispatch_async(dispatch_get_main_queue(), ^{
								   if (response) {
									   
									   
									   // Build an array from the dictionary for easy access to each entry
									   NSArray *photos = [[response objectForKey:@"photos"] objectForKey:@"photo"] ;
									   
									   for (NSDictionary *photo in photos)
									   {
										   
										   FKFlickrPhotosGeoGetLocation *location = [[FKFlickrPhotosGeoGetLocation alloc] init];
										   location.photo_id = [photo objectForKey:@"id"];
										   
										   [[FlickrKit sharedFlickrKit] call:location
																  completion:^(NSDictionary *response, NSError *error) {
											   // Note this is not the main thread!
											   if (response) {
												   
												   dispatch_async(dispatch_get_main_queue(), ^{
													   
													   CLLocationCoordinate2D coordinate;
													   coordinate.latitude = [[[[response objectForKey:@"photo"] objectForKey:@"location"] objectForKey:@"latitude"] doubleValue];
													   coordinate.longitude = [[[[response objectForKey:@"photo"] objectForKey:@"location"]  objectForKey:@"longitude"] doubleValue];
													   
													   JENLocation *location = [[JENLocation alloc]
																				initWithLocation:coordinate];
													   [self.mapView addAnnotation:location];
													   
													   NSLog(@"added annotaion at %f : %f", coordinate.latitude, coordinate.longitude);
													   
													   
													   [locations addObject:location];
												   });
											   }
										   }];
									   }
									   
								   } else {
									   // show the error
								   }
							   });
						   }];
	 
	 

	
	/*CLLocationCoordinate2D coordinate1;
	coordinate1.latitude = -37.797100;
	coordinate1.longitude = 144.959453;
	JENLocation *location1 = [[JENLocation alloc]
							 initWithLocation:coordinate1];
	[self.mapView addAnnotation:location1];
	NSLog(@"added annotaion at %f : %f", coordinate1.latitude, coordinate1.longitude);
	[locations addObject:location1];
	
	CLLocationCoordinate2D coordinate2;
	coordinate2.latitude = -37.796014;
	coordinate2.longitude = 144.944347;
	JENLocation *location2 = [[JENLocation alloc]
							  initWithLocation:coordinate2];
	[self.mapView addAnnotation:location2];
	NSLog(@"added annotaion at %f : %f", coordinate2.latitude, coordinate2.longitude);
	[locations addObject:location2];
	
	CLLocationCoordinate2D coordinate3;
	coordinate3.latitude = -37.807408;
	coordinate3.longitude = 144.949497;
	JENLocation *location3 = [[JENLocation alloc]
							  initWithLocation:coordinate3];
	[self.mapView addAnnotation:location3];
	NSLog(@"added annotaion at %f : %f", coordinate3.latitude, coordinate3.longitude);
	[locations addObject:location3];
	
	CLLocationCoordinate2D coordinate4;
	coordinate4.latitude = -37.792568;
	coordinate4.longitude = 144.931210;
	JENLocation *location4 = [[JENLocation alloc]
							  initWithLocation:coordinate4];
	[self.mapView addAnnotation:location4];
	NSLog(@"added annotaion at %f : %f", coordinate4.latitude, coordinate4.longitude);
	[locations addObject:location4];
	
	CLLocationCoordinate2D coordinate5;
	coordinate5.latitude = -37.786463;
	coordinate5.longitude = 144.957131;
	JENLocation *location5 = [[JENLocation alloc]
							  initWithLocation:coordinate5];
	[self.mapView addAnnotation:location5];
	NSLog(@"added annotaion at %f : %f", coordinate5.latitude, coordinate5.longitude);
	[locations addObject:location5];	*/
}

-(void)viewDidAppear:(BOOL)animated {
	
	
	CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = -37.796014;
    zoomLocation.longitude= 144.944347;
	
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5*METERS_PER_MILE, 5*METERS_PER_MILE);
	
    // 3
    [self.mapView setRegion:viewRegion animated:YES];
}

- (IBAction)redrawRouteButtonPressed:(UIButton *)sender {
	
	JENTourPlanner* tourplanner = [[JENTourPlanner alloc] initWithTourLocations:locations
																	 Population:100];
	NSLog(@"lenght of shortest tour: %f", [[tourplanner getShortestTour] getLenghtOfTour]);

	[tourplanner evolveTours];
	
	NSLog(@"lenght of shortest tour: %f", [[tourplanner getShortestTour] getLenghtOfTour]);
	
	locations = [[tourplanner getShortestTour] locations];
	
	[self showLines];
	// go through locations and find a route, and then draw it
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showLines {
	
    CLLocationCoordinate2D *pointsCoordinate = (CLLocationCoordinate2D *)
	malloc(sizeof(CLLocationCoordinate2D) * [locations count] + 1);
	
	for (int i = 0; i < [locations count]; ++i) {
		pointsCoordinate[i] = [locations[i] coordinate];
	}

	pointsCoordinate[[locations count]] = [locations[0] coordinate];
	
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:pointsCoordinate
														 count:[locations count] + 1];
    free(pointsCoordinate);
	
    [self.mapView addOverlay:polyline];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	
	MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:5/255. green:5/255. blue:5/255. alpha:1.0];
    polylineView.lineWidth = 2;
	
    return polylineView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *annotaionIdentifier=@"annotationIdentifier";
    MKPinAnnotationView *aView=(MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier ];
    if (aView==nil) {
		
        aView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotaionIdentifier];
        aView.pinColor = MKPinAnnotationColorRed;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //        aView.image=[UIImage imageNamed:@"arrow"];
        aView.animatesDrop=TRUE;
        aView.canShowCallout = YES;
        aView.calloutOffset = CGPointMake(-5, 5);
    }
	
    return aView;
}

@end
