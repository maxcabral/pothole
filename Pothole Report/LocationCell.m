//
//  self.m
//  Pothole Report
//
//  Created by William Ha on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "LocationCell.h"

@interface LocationCell()

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@end

@implementation LocationCell

@synthesize dateLabel, addressLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)styleView:(Location*)location
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }
    self.dateLabel.text = [formatter stringFromDate:location.date];
    
    if ([location.locationDescription length] > 0) {
        self.addressLabel.text = location.locationDescription;
    } else {
        self.addressLabel.text = [NSString stringWithFormat:
                                      @"Lat: %.8f\nLong: %.8f",
                                      [location.latitude doubleValue],
                                      [location.longitude doubleValue]];
    }
}

@end
