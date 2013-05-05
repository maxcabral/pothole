//
//  Location.h
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface phLocation : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic) BOOL post;
+ (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark;
+ (NSString *)printableDescription:(NSManagedObject*)managedObj;
- (NSString *)description;
@end
