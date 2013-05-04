//
//  Pothole_ReportTests.m
//  Pothole ReportTests
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "Pothole_ReportTests.h"

@implementation Pothole_ReportTests

- (void)setUp
{
    [super setUp];
    laSubmission = [[phLosAngelesSubmission alloc] init];
    laSubmission.delegate = self;
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSubmit
{
    [laSubmission submitWithName:@"MAX" Address:@"100 Main St" Phone:@"8001234567" Email:@"max@maxcabral.com" Description:@"Massive Pothole" Comment:@"This is a test" AndLocation:@"Los Angeles"];
    //STFail(@"Unit tests are not implemented yet in Pothole ReportTests");
}

- (void)handleResponse:(NSDictionary*)response
{
    if (!response){
        STFail(@"Response object is nil");
    }

    for (NSString* key in response){
        NSLog(@"%@ - %@",key,[response objectForKey:key]);
    }
}

@end
