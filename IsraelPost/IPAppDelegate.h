//
//  IPAppDelegate.h
//  IsraelPost
//
//  Created by Uri Kogan on 11/2/12.
//  Copyright (c) 2012 Uri Kogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IPAppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDataDelegate>
{
    NSMutableData *_data;
}

@property (weak) IBOutlet NSTextField *fieldNumber;
@property (weak) IBOutlet NSTextField *labelStatus;
@property (assign) IBOutlet NSWindow *window;

- (IBAction)checkButtonClicked:(id)sender;

@end
