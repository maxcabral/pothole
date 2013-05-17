//
//  Location.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "Location.h"
#import "phAppDelegate.h"

@interface Location ()

@property (nonatomic, setter = setCoordinate:, getter = coordinate) CLLocationCoordinate2D coordinate;
@end

@implementation Location
@synthesize coordinate;

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic placemark;
@dynamic post;


- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    
}

- (NSString *)title
{
    if ([self.locationDescription length] > 0) {
        return self.locationDescription;
    } else {
        return @"(No Description)";
    }
}

- (NSString *)description
{
    return [Location printableDescription:self];
}

- (void)geoLocate:(void (^)(Location*))callback
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
        self.placemark = [placemarks lastObject];

        NSError *saveError;
        if (![[self managedObjectContext] save:&saveError]){
            
        }
    }];
}

- (NSString *)placemarkDescription
{
    NSString *desc = [Location stringFromPlacemark:self.placemark];
    
    if ([desc isEqualToString:@" \n  "]){
        desc = [NSString stringWithFormat:@"Unable to Geolocate. Coordinates - %@ x %@",self.latitude,self.longitude];
    }
    
    return desc;
}

+ (NSString *)printableDescription:(Location*)managedObj
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-DD"];
    return [NSString stringWithFormat:@"Date: %@\nLat: %@ Long: %@\nApproximate Address: %@",
            [dateFormat stringFromDate:managedObj.date],
            managedObj.latitude,
            managedObj.longitude,
            managedObj.locationDescription];
}

+ (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare,
            thePlacemark.thoroughfare,
            thePlacemark.locality,
            thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

+ (Location *)locationFromCLLocation:(CLLocation *)location andPlaceMark:placemark;
{
    NSManagedObjectContext *context = ((phAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    Location *potholeLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext: context ];
    
    potholeLocation.locationDescription = [self stringFromPlacemark:placemark];
    potholeLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    potholeLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    potholeLocation.date = [NSDate date];
    potholeLocation.placemark = placemark;
    
    NSError *error;
    if (![context save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
    }
    return potholeLocation;
}



@end