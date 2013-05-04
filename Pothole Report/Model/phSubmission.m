//
//  phSubmission.m
//  Pothole Report
//
//  Created by Maxwell Cabral on 5/4/13.
//  Copyright (c) 2013 Pothole. All rights reserved.
//

#import "phSubmission.h"

@implementation phSubmission
@synthesize delegate, submissionUrl;

- (id)init
{
    self = [super init];
    if (self){
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)setSubmissionUrl:(NSString *)newValue
{
    submissionUrl = newValue;
}

-(void)submit:(NSDictionary*)fields
{    
    NSURL *url = [NSURL URLWithString:self.submissionUrl];
    NSMutableString *ReqString;
    
    //AsynchronousRequest to grab the data
    int fieldCount = [fields count];
    int currentCount = 0;
    for (NSString* key in fields) {
        [ReqString appendString:[NSString stringWithFormat:@"%@=%@",key,[fields objectForKey:key]]];

        if (++currentCount < fieldCount){
            [ReqString appendString:@"&"];
        }
    }
    NSLog(@"Debug: Request string - %@",ReqString);
    return;
    
    
    NSData *ReqData = [NSData dataWithBytes: [ReqString UTF8String] length: [ReqString length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:ReqData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self->queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSDictionary* Response;
        NSString* ResponseMessage;
        NSString* RawResponse;
        if ([data length] > 0 && error == nil){
            ResponseMessage = @"success";
            RawResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        else if ([data length] == 0 && error == nil)
        {
         //empty data
            ResponseMessage = @"no data";
        }
        //used this NSURLErrorTimedOut from foundation error responses
        else if (error != nil && error.code == NSURLErrorTimedOut)
        {
         //timeout
            ResponseMessage = @"timeout";
        }
        else if (error != nil)
        {
         //generic error
            ResponseMessage = @"generic error";
        }
        Response = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:ResponseMessage,RawResponse,nil]
                                                 forKeys:[[NSArray alloc] initWithObjects:@"message",@"response",nil]];
        [self.delegate performSelectorOnMainThread:@selector(handleResponse:)
                                        withObject:Response
                                     waitUntilDone:NO];
    }];
    
    //return YES;
}


@end
