//
//  HolesViewController.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "HolesViewController.h"
#import "Location.h"

@interface HolesViewController ()

@end

@implementation HolesViewController {
    NSArray *locations;
}

@synthesize managedObjectContext;

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    
    Location *location = [locations objectAtIndex:indexPath.row];
    
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
    descriptionLabel.text = location.locationDescription;
    
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
    addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                         location.placemark.subThoroughfare,
                         location.placemark.thoroughfare,
                         location.placemark.locality];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    locations = foundObjects;
}

@end