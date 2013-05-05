//
//  MapViewController.h
//  Pothole Report
//
//  Created by William Ha on 5/5/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

- (IBAction)showUser;
- (IBAction)showLocations;

@end