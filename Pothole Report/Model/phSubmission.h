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
    NSOperationQueue *queue;
}
@property (weak) NSObject<phSubmissionResponse>* delegate;
@property (readonly,nonatomic) NSString* submissionUrl;
-(void)submit:(NSDictionary*)fields;
@end
