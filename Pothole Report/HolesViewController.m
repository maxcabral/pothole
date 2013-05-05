//
//  HolesViewController.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "HolesViewController.h"
#import "Location.h"
#import "LocationCell.h"

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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location = [locations objectAtIndex:indexPath.row];
    
    if ([location.locationDescription length] > 0) {
        locationCell.descriptionLabel.text = location.locationDescription;
    } else {
        locationCell.descriptionLabel.text = @"(No Description)";
    }
    
    if (location.placemark != nil) {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                                          location.placemark.subThoroughfare,
                                          location.placemark.thoroughfare,
                                          location.placemark.locality];
    } else {
        locationCell.addressLabel.text = [NSString stringWithFormat:
                                          @"Lat: %.8f, Long: %.8f",
                                          [location.latitude doubleValue],
                                          [location.longitude doubleValue]];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        HolesViewController
    }
}

@end