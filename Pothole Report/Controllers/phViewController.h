//
//  phViewController.h
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//



@interface phViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *tagButton;
@property (nonatomic, strong) IBOutlet UIButton *getButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *emailButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)getphLocation:(id)sender;

@end
