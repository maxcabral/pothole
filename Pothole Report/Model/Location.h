//
//  Location.h
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic) BOOL post;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (NSString *)description;
- (void)geoLocateIfNecessary:(void (^)(Location*,NSError*))callback;
- (void)geoLocate:(void (^)(Location*,NSError*))callback;
- (NSString *)placemarkDescription;

+ (Location *)locationFromCLLocation:(CLLocation *)location andPlaceMark:placemark;
+ (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark;
+ (NSString *)printableDescription:(NSManagedObject*)managedObj;

@end
