//
//  JENMapViewController.h
//  IttyBittyMaps
//
//  Created by Jennifer Nordwall on 16/02/15.
//  Copyright (c) 2015 Jennifer Nordwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface JENMapViewController : UIViewController<MKMapViewDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(weak, nonatomic) IBOutlet UIButton *routeButton;

- (IBAction)redrawRouteButtonPressed:(UIButton *)sender;
- (void)showLines;
@end
