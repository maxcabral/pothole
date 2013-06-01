//
//  phdetailsViewController.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//


#import "MBProgressHUD.h"
#import "phViewController.h"
#import "phdetailsViewController.h"
#import "Location.h"

@interface phdetailsViewController () {
    NSString *descriptionText;
    NSDate *date;
}
@end

@implementation phdetailsViewController 

@synthesize descriptionTextView; 
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize dateLabel;
@synthesize coordinate;
@synthesize managedObjectContext;
@synthesize location;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        descriptionText = @"";
        date = [NSDate date];
    }
    return self;
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    [self.descriptionTextView resignFirstResponder];
}

- (void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.3];
}

- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}

- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.text = descriptionText;
    self.dateLabel.text = [self formatDate:date];

    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    
    if (self.location != nil) {
        self.addressLabel.text = [Location stringFromPlacemark:self.location.placemark];
    } else {
        self.addressLabel.text = @"No Address Found";
    }
    
    self.dateLabel.text = [self formatDate:[NSDate date]];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(hideKeyboard:)];
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.location != nil && self.location.placemark == nil){
        [self.location performSelectorInBackground:@selector(geoLocate:) withObject:^(Location *thisLoc,NSError *saveError) {
            if (saveError == nil){
                NSLog(@"Updated geolocation");
                if (self != nil) {
                    [self performSelectorOnMainThread:@selector(setLocation:) withObject:thisLoc waitUntilDone:NO];
                }
            } else {

            }
        }];
    }
}

- (void)setLocation:(Location *)newlocation
{
    if (location != newlocation) {
        location = newlocation;
        
        descriptionText = location.description;
        self.coordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
        date = location.date;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 120;
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        
        CGRect rect = CGRectMake(100, 10, 190, 1000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
    } else {
        return 44;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    descriptionText = theTextView.text;
}

@end