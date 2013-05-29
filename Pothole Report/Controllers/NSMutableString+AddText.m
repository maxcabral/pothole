//
//  NSMutableString+AddText.m
//  iSpotHoles
//
//  Created by William Ha on 5/21/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if (text) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        
        [self appendString:text];
    }
}

@end
