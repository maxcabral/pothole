//
//  phLosAngelesSubmission.m
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phLosAngelesSubmission.h"

@implementation phLosAngelesSubmission

-(void)submitWithName:(NSString*)name Address:(NSString*)address Phone:(NSString*)phone Email:(NSString*)email Description:(NSString*)desc Comment:(NSString*)comment AndLocation:(NSString*)loc
{
    NSLog(@"Testing");
    NSDictionary* request = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:
                                                                  @"You+must+enter+a+Name",
                                                                  @"You+must+enter+a+Phone+Number",
                                                                  @"Pothole+or+Request+for+Street+Repairs",
                                                                  name,
                                                                  address,
                                                                  phone,
                                                                  email,
                                                                  desc,
                                                                  loc,
                                                                  comment,
                                                                   nil]
                                                        forKeys:[[NSArray alloc] initWithObjects:
                                                                 @"name_required",
                                                                 @"phone_required",
                                                                 @"type",
                                                                 @"name",
                                                                 @"address",
                                                                 @"phone",
                                                                 @"email",
                                                                 @"desc",
                                                                 @"loc",
                                                                 @"comment",
                                                                 nil]];
    [self submit:request];
/*
 @"http://nss/;acity.org/request.cfm"
 @"name_required = @"You+must+enter+a+Name"
 @"phone_required = @"You+must+enter+a+Phone Number"
 @"type", = @"Pothole+or+Request+for+Street+Repairs"
 @"name",
 @"address",
 @"phone",
 @"email",
 @"desc",
 @"loc",
 @"comment",
 */
}
@end
