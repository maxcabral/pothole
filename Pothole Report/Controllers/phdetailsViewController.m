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

#import <QuartzCore/QuartzCore.h>

@interface phdetailsViewController () {

}
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@end

@implementation phdetailsViewController 

@synthesize descriptionTextView; 
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize dateLabel;
@synthesize managedObjectContext;
@synthesize location;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {

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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ps_neutral"]]];
    
    [self setLabels];
    
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
                    [self performSelectorOnMainThread:@selector(setLabels) withObject:nil waitUntilDone:NO];
                }
            } else {

            }
        }];
    }
}

- (void)setLabels
{
    self.descriptionTextView.text = self.location.description;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%@", self.location.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%@", self.location.longitude];
    
    if (self.location.placemark != nil) {
        self.addressLabel.text = [Location stringFromPlacemark:self.location.placemark];
    } else {
        self.addressLabel.text = @"No Address Found";
    }
    
    self.dateLabel.text = [self formatDate:location.date];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 120;
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

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    const float _labelY = 18.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width,40.0)];
    UILabel *headerLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, _labelY, 100.0,20.0)];
    [headerLeftLabel setFont:[UIFont fontWithName:@"Thonburi-Bold" size:20.0]];
    
    headerLeftLabel.backgroundColor = [UIColor clearColor];
    

    if (section == 0){
        /*here we return a custom view for the header*/
        headerLeftLabel.text = @"Description";
        
        NSString *postMessage;
        float _rLabelX;
        
        if (self.location.post){
            postMessage = @"Sent \u2714";
            _rLabelX = tableView.bounds.size.width - 70.0;
        } else {
            postMessage = @"Not Sent \u2718";
            _rLabelX = tableView.bounds.size.width - 110.0;
        }
        
        UILabel *headerRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(_rLabelX, _labelY, 90.0,20.0)];
        headerRightLabel.backgroundColor = [UIColor clearColor];
        headerRightLabel.text = postMessage;
        
        if (self.location.post){
            headerRightLabel.textColor = [UIColor colorWithRed:0.351 green:0.793 blue:0.173 alpha:1.000];
        } else {
            headerRightLabel.textColor = [UIColor colorWithRed:0.793 green:0.362 blue:0.197 alpha:1.000];
        }
        
        [headerView addSubview:headerRightLabel];
        
        /*I also want the header to throw a shadow on the rest of the table*/
        /*headerview.layer.shadowColor = [[UIColor blackColor] CGColor];
        headerview.layer.shadowOffset = CGSizeMake(0, 0);
        headerview.layer.shadowOpacity = 0.5f;
        headerview.layer.shadowRadius = 3.25f;
        headerview.layer.masksToBounds = NO;*/
    } else if (section == 1){
        headerLeftLabel.text = @"Data";
    } else {
        headerLeftLabel.text = @"Customize Me";
    }
    
    [headerView addSubview:headerLeftLabel];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
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
    //descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    //descriptionText = theTextView.text;
}

@end