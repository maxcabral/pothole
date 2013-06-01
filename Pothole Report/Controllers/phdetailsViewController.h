//
//  phdetailsViewController.h
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@class Location;

@interface phdetailsViewController : UITableViewController <UITextViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Location *location;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end