//
//  phViewController.m
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phViewController.h"
#import "phLosAngelesSubmission.h"
#import "phdetailsViewController.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "phLocation.h"


@interface phViewController()

- (void)updateLabels;

@end

@implementation phViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    NSError *lastGeocodingError;
    phLosAngelesSubmission *laSubmission;
    MBProgressHUD *hudView;
    NSMutableArray *mutableFetchResults;
}

@synthesize addressLabel, tagButton, emailButton, managedObjectContext;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagPothole"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        phdetailsViewController *controller = (phdetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.coordinate = location.coordinate;
        controller.placemark = placemark;
        
    }
}

- (IBAction)getphLocation:(id)sender

{
    if (!updatingLocation) {
        hudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hudView.labelText = @"Processing";

        self.addressLabel.text = @"Searching for Address...";
        location = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError = nil;
        NSLog(@"%@",@"Starting manager");
        [self startLocationManager];
    }
    
    [self updateLabels];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

- (void)updateLabels
{
    if (location != nil) {
        
        if (placemark !=nil) {
            self.addressLabel.text = [self stringFromPlacemark:placemark];
        } else if (lastGeocodingError != nil) {
            self.addressLabel.text = @"Error Finding Address";
        } else if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied) {
                self.addressLabel.text = @"Location Services Disabled";
            } else {
                self.addressLabel.text = @"Error Getting Location";
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            self.addressLabel.text = @"Location Services Disabled";
        }
        
    }
}

- (void)savePothole
{
    phLocation *potholeLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];

    potholeLocation.locationDescription = [self stringFromPlacemark:placemark];
    potholeLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    potholeLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    potholeLocation.date = [NSDate date];
    potholeLocation.placemark = placemark;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager
{
    if (updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [locationManager stopUpdatingLocation];
        updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"*** Time out");
    
    if (location == nil) {
        [self stopLocationManager];
        
        lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    laSubmission = [[phLosAngelesSubmission alloc] init];
    laSubmission.delegate = (id)self;
    [self updateLabels];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = error;
    
    [self updateLabels];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation %@", newLocation);
    
    CLLocationDistance distance = MAXFLOAT;
    if (location != nil) {
        distance = [newLocation distanceFromLocation:location];
    }
    
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        location = newLocation;
        [self updateLabels];
        
        [self stopLocationManager];

        NSLog(@"*** Going to geocode");
        
        if (!performingReverseGeocoding){
            performingReverseGeocoding = YES;
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                
                lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                } else {
                    placemark = nil;
                }
                
                performingReverseGeocoding = NO;
                [self stopLocationManager];
                [self updateLabels];
                [self savePothole];
                [hudView hide:YES];
            }];
        }

        
        [self updateLabels];
        
        
    }
}

@end

/********
 
 Submission class response handler
 
 ********/
@interface phViewController (SubmissionResponseHandler) <phSubmissionResponse>

@end

@implementation phViewController (SubmissionResponseHandler)
- (void)handleResponse:(NSDictionary*)response
{
    for (NSString* key in response){
        NSLog(@"%@ - %@",key,[response objectForKey:key]);
    }
}
@end

@interface phViewController (EmailView)

@end

@implementation phViewController (EmailView)

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Pothole report";
    // Email Content
    NSString *messageBody = [self reportBody];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"max@maxcabral.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = (id)self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (NSString*)reportBody
{
    NSMutableString *report = [[NSMutableString alloc] init];

    mutableFetchResults = [self getUnsentReports];
    if (mutableFetchResults == nil) {
        // Handle the error.
    } else {
        int cnt = 1;
        for (phLocation *locRecord in mutableFetchResults) {
            [report appendString:[NSString stringWithFormat:@"Report #%i\n",cnt++]];
            [report appendString:[phLocation printableDescription:locRecord]];
            [report appendString:@"\n\n----------\n\n"];
        }

    }
    
    return [report copy];
}

- (NSMutableArray*)getUnsentReports
{
    NSFetchedResultsController* fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSSortDescriptor *postedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"post" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:postedDescriptor]];
    
    [fetchRequest setFetchBatchSize:20];
    
    fetchedResultsController = [[NSFetchedResultsController alloc]
                                initWithFetchRequest:fetchRequest
                                managedObjectContext:self.managedObjectContext
                                sectionNameKeyPath:nil
                                cacheName:@"Locations"];
    NSError *error = nil;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (phLocation *locReport in [managedObjectContext executeFetchRequest:fetchRequest error:&error]) {
        if (!locReport.post){
            [results addObject:locReport];
        }
    }
    return results;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
            for (phLocation *locRecord in [self getUnsentReports]) {
//                [locRecord setPost:YES];
            }
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                FATAL_CORE_DATA_ERROR(error);
            }
            break;
        }
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

@interface phViewController (UISwitchControllerDelegate)
{
    
}
@end

@implementation phViewController (UISwitchControllerDelegate)

- (IBAction)drivingSwitchValueChanged:(UISwitch *)sender {
    if (sender.on){
        [self disableControls];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else {
        [self enableControls];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)disableControls
{
    [self.tagButton setEnabled:NO];
    [self.emailButton setEnabled:NO];
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
}

- (void)enableControls
{
    [self.tagButton setEnabled:YES];
    [self.emailButton setEnabled:YES];
    [self.tabBarController.tabBar setUserInteractionEnabled:YES];
}

@end