//
//  FKAppDelegate.m
//  FlickrKitDemo
//
//  Created by David Casserly on 03/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKAppDelegate.h"
#import "FKViewController.h"
#import "FlickrKit.h"

@implementation FKAppDelegate

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *scheme = [url scheme];
	if([@"flickrkitdemo" isEqualToString:scheme]) {
		// I don't recommend doing it like this, it's just a demo... I use an authentication
		// controller singleton object in my projects
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthCallbackNotification" object:url userInfo:nil];			
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {		

	// Initialise FlickrKit with your flickr api key and shared secret
	NSString *apiKey = @"cdc874a5628a18d2012264a07b049e90";
	NSString *secret = @"789217d2a8eded5c";
    if (!apiKey) {
        NSLog(@"\n----------------------------------\nYou need to enter your own 'apiKey' and 'secret' in FKAppDelegate for the demo to run. \n\nYou can get these from your Flickr account settings.\n----------------------------------\n");
        exit(0);
    }
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
	
		
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    
		self.viewController = [[FKViewController alloc] initWithNibName:@"FKViewController_iPhone" bundle:nil];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
		
	}
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
