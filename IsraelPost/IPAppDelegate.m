//
//  IPAppDelegate.m
//  IsraelPost
//
//  Created by Uri Kogan on 11/2/12.
//  Copyright (c) 2012 Uri Kogan. All rights reserved.
//

#import "IPAppDelegate.h"
#import "TFHpple.h"

@implementation IPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)checkButtonClicked:(id)sender
{
    _data = [[NSMutableData alloc] init];

    NSString *requestUrl =
    [[NSString alloc] initWithFormat:
     @"http://www.israelpost.co.il/itemtrace.nsf/trackandtraceJSON?OpenAgent&itemcode=%@",
     [[self fieldNumber] stringValue]];

    NSURL *url = [NSURL URLWithString:requestUrl];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    [conn start];

    [[self labelStatus] setStringValue:@"Looking up package"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *contentType = [headers valueForKey:@"Content-Type"];
    if ([contentType length] <= 0)
    {
        [connection cancel];
        [[self labelStatus] setStringValue:@"Invalid response type"];
        return;
    }

    if ([contentType rangeOfString:@"application/j-son"].location == NSNotFound)
    {
        [connection cancel];
        NSString *err = [[NSString alloc] initWithFormat:@"Invalid content type: %@", contentType];
        [[self labelStatus] setStringValue:err];
        return;
    }
}

- (NSString *)readStatusFromData:(NSData *)data
{
    NSError *error;
    
    NSDictionary *json =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:kNilOptions
                                      error:&error];
    NSString *info = [json objectForKey:@"itemcodeinfo"];
    if ([info rangeOfString:@"<table"].location == NSNotFound)
    {
        return info;
    }

    TFHpple *tp =
    [TFHpple hppleWithHTMLData:[info dataUsingEncoding:NSUTF8StringEncoding]];

    NSArray *cols = [tp searchWithXPathQuery:@"//table/tr/td"];

    if ([cols count] <= 0)
    {
        return @"";
    }

    TFHppleElement *stat = [cols objectAtIndex:0];
    return  [[stat firstChild] content];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self labelStatus] setStringValue:[self readStatusFromData:_data]];
}

@end
