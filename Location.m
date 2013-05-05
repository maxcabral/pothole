//
//  Location.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "Location.h"

@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic placemark;


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



@end