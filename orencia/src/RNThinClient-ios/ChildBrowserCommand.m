//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//  Copyright 2012, Randy McMillan
// Continued maintainance @RandyMcMillan 2010/2011/2012

#import "ChildBrowserCommand.h"

#ifdef PHONEGAP_FRAMEWORK
	#import <PhoneGap/PhoneGapViewController.h>
#endif
//#else
#ifdef CORDOVA_FRAMEWORK
#import <Cordova/CDVViewController.h>
#endif


@implementation ChildBrowserCommand

@synthesize childBrowser;

- (void) showWebPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options // args: url
{	
	if(childBrowser == NULL)
	{
		childBrowser = [[ ChildBrowserViewController alloc ] initWithScale:FALSE ];
		childBrowser.delegate = self;
	}
	
#ifdef PHONEGAP_FRAMEWORK
	PhoneGapViewController* cont = (PhoneGapViewController*)[ super appViewController ];
	childBrowser.supportedOrientations = cont.supportedOrientations;
    @try {
        [cont presentModalViewController:childBrowser animated:YES ];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to open childbrower view. Failing silently. Exception: %@", exception);
    }
#endif
    
#ifdef CORDOVA_FRAMEWORK
    CDVViewController* cont = (CDVViewController*)[ super viewController ];
	childBrowser.supportedOrientations = cont.supportedOrientations;
    @try {
        [cont presentModalViewController:childBrowser animated:YES ];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to open childbrower view. Failing silently. Exception: %@", exception);
    }
#endif
    
	NSString *url = (NSString*) [arguments objectAtIndex:0];

	[childBrowser loadURL:url  ];
}

-(void) close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options // args: url
{
	[ childBrowser closeBrowser];
	
}

-(void) onClose
{
	NSString* jsCallback = @"ChildBrowser._onClose();";
    @try {
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallback];
    }
    @catch (NSException *exception) {
        NSLog(@"onClose self.webview =>stringByEvaluatingJavaScriptFromString => Failing silently. Exception: %@", exception);
    }
}

-(void) onOpenInSafari
{
	NSString* jsCallback = @"ChildBrowser._onOpenExternal();";
	[self.webView stringByEvaluatingJavaScriptFromString:jsCallback];
}


-(void) onChildLocationChange:(NSString*)newLoc
{
	
	NSString* tempLoc = [NSString stringWithFormat:@"%@",newLoc];
	NSString* encUrl = [tempLoc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	 
	NSString* jsCallback = [NSString stringWithFormat:@"ChildBrowser._onLocationChange('%@');",encUrl];
	[self.webView stringByEvaluatingJavaScriptFromString:jsCallback];

}

- (void) doCommand:(NSString*)command WithParameters:(NSDictionary*) parameters {
    
    if(command.length) {
        
        NSString *paramsAsString = @"null";
        
        if(parameters) {
            NSString *params = @"";
            for (NSString* key in parameters) {
                NSString *param = [parameters objectForKey:key];
                if(![param isEqualToString:@"true"] && ![param isEqualToString:@"false"] && ![param intValue]) {
                    param = [NSString stringWithFormat:@"\"%@\"", param];
                }
                                                       
                params = [params stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@,", key, param]];
            }            
            
            paramsAsString = [NSString stringWithFormat:@"{%@}", [params substringToIndex:params.length-1]];
        }
        
        NSString *jsCallback = [NSString stringWithFormat:@"ChildBrowser._onCommand(\"%@\", %@);", command, paramsAsString];
        @try {
            [self.webView stringByEvaluatingJavaScriptFromString:jsCallback];
        }
        @catch (NSException *exception) {
            NSLog(@"onCommand self.webview =>stringByEvaluatingJavaScriptFromString => Failing silently. Exception: %@", exception);    
        }        
        
    }
}


@end
