//
//  Pothole_ReportTests.h
//  Pothole ReportTests
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "phLosAngelesSubmission.h"

@interface Pothole_ReportTests : SenTestCase <phSubmissionResponse>
{
    phLosAngelesSubmission *laSubmission;
}

@end
