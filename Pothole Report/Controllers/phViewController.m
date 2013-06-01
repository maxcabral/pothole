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
#import "Location.h"
#import "NSMutableString+AddText.h"


@interface phViewController()

@end

@implementation phViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
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
        //controller.coordinate = location.coordinate;
        //controller.placemark = placemark;
        
    }
}

- (IBAction)getphLocation:(id)sender
{
    hudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudView.labelText = @"Processing";

    self.addressLabel.text = @"Searching for Address...";
    NSLog(@"%@",@"Starting manager");
    [self startLocationManager];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateLabelsWithMessage:(NSString*)message
{
    if (message){
        self.addressLabel.text = message;
    } else {
        self.addressLabel.text = @"Processing...";
    }
}

- (void)updateLabelsWithLocation:(Location *)newLocation
{
    if (newLocation != nil) {
        
        if (newLocation.placemark != nil) {
            self.addressLabel.text = newLocation.locationDescription;
        } else if (newLocation.latitude != nil){
            self.addressLabel.text = [NSString stringWithFormat:@"%@.4 x %@.4",newLocation.latitude,newLocation.longitude];
        } else {
            self.addressLabel.text = @"Unable to Save Pothole";
        }
        
    } else {
        
        if (![CLLocationManager locationServicesEnabled]) {
            self.addressLabel.text = @"Location Services Disabled";
        } else {
            self.addressLabel.text = @"Unable to Save Pothole";
        }
        
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    [locationManager stopUpdatingLocation];
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"*** Time out");
    [self stopLocationManager];
    
    [self updateLabelsWithMessage:@"Location Services Timed Out"];
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
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    [self stopLocationManager];
    [self updateLabelsWithMessage:@"Unable to fix location"];
    [hudView hide:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self stopLocationManager];
    
    NSLog(@"didUpdateToLocation %@", newLocation);
    
    [self updateLabelsWithMessage:nil];
    

    NSLog(@"*** Going to geocode");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
        Location *newLocationModel;
        
        if (error == nil && [placemarks count] > 0) {
            newLocationModel = [Location locationFromCLLocation:newLocation andPlaceMark:[placemarks lastObject]];
        } else {
            newLocationModel = [Location locationFromCLLocation:newLocation andPlaceMark:nil];
        }

        
        [self updateLabelsWithLocation:newLocationModel];
        
        [hudView hide:YES];
    }];
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
    // In case something goes wrong...
    UIAlertView *emailErrorAlert;
    
    if (messageBody == nil){
        emailErrorAlert = [[UIAlertView alloc] initWithTitle:@"Processing Error"
                                                                  message:@"Sorry, I was unable to process your stored Potholes. Please try again.\n\nIf this error persists, you may want to quit and reopen the app."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    } else if ([messageBody isEqualToString:@""]){
        emailErrorAlert = [[UIAlertView alloc] initWithTitle:@"Nothing to Send"
                                                                  message:@"Woohoo! You have no Potholes that need to be sent. That means they're being fixed, right?"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    }
    
    //If we have an error to display, do it and return
    if (emailErrorAlert != nil){
        [emailErrorAlert show];
        return;
    }
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"bss.boss@lacity.org"];
    
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
        // Handle the error in the caller.
        return nil;
    } else {
        int cnt = 1;
        for (Location *locRecord in mutableFetchResults) {
            [report appendString:[NSString stringWithFormat:@"Report #%i\n",cnt++]];
            [report appendString:[Location printableDescription:locRecord]];
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
    for (Location *locReport in [managedObjectContext executeFetchRequest:fetchRequest error:&error]) {
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
            for (Location *locRecord in [self getUnsentReports]) {
                [locRecord setPost:YES];
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