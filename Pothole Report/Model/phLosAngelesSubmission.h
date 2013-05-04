//
//  phLosAngelesSubmission.h
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phSubmission.h"

@interface phLosAngelesSubmission : phSubmission
-(void)submitWithName:(NSString*)name Address:(NSString*)address Phone:(NSString*)phone Email:(NSString*)email Description:(NSString*)desc Comment:(NSString*)comment AndLocation:(NSString*)loc;
@end
