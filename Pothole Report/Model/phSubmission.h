//
//  phSubmission.h
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol phSubmissionResponse
- (void)handleResponse:(NSDictionary*)response;

@end

@interface phSubmission : NSObject
{
    
}
@property (weak) id<phSubmissionResponse> delegate;
-(void)submit:(NSDictionary*)fields;
@end
