//
//  phdetailsViewController.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phdetailsViewController.h"

@interface phdetailsViewController ()

@end

@implementation phdetailsViewController

@synthesize descriptionTextView;
@synthesize categoryLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize dateLabel;


- (void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self closeScreen];
    
}

- (IBAction)cancel:(id)sender
{
}

@end