//
//  Location.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "Location.h"

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
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}



@end