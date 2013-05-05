//
//  HolesViewController.h
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HolesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
