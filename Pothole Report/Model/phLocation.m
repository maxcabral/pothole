//
//  Location.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phLocation.h"

@implementation phLocation

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

- (NSString *)title
{
    if ([self.locationDescription length] > 0) {
        return self.locationDescription;
    } else {
        return @"(No Description)";
    }
}

- (void)savePotholeWithLocation:(CLLocation*)location andPlaceMark:(CLPlacemark*)placemark
{
    phLocation *potholeLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    potholeLocation.locationDescription = [phLocation stringFromPlacemark:placemark];
    potholeLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    potholeLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    potholeLocation.date = [NSDate date];
    potholeLocation.placemark = placemark;
}

+ (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}



@end