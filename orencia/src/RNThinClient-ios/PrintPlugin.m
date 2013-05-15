//
//  PrintPlugin.m
//  Print Plugin
//
//  Created by Ian Tipton (github.com/itip) on 02/07/2011.
//  Copyright 2011 Ian Tipton. All rights reserved.
//  MIT licensed
//

#import "PrintPlugin.h"

@interface PrintPlugin (Private)
-(void) doPrint;
-(void) callbackWithFuntion:(NSString *)function withData:(NSString *)value;
-(BOOL) isPrintServiceAvailable;
@end

@implementation PrintPlugin

@synthesize successCallback, failCallback, printHTML, dialogTopPos, dialogLeftPos, webPrintView;

- (void) dealloc {
    
    if(self.webPrintView) {
        self.webPrintView.delegate = nil;
        self.webPrintView = nil;
    }
    
    [successCallback release];
    [failCallback release];
    [printHTML release];
    
    [super dealloc];
}

/*
 Is printing available. Callback returns true/false if printing is available/unavailable.
 */
- (void) isPrintingAvailable:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSUInteger argc = [arguments count];
	
	if (argc < 1) {
		return;	
	}
    
    NSString *callBackFunction = [arguments objectAtIndex:0];
    [self callbackWithFuntion:callBackFunction withData:
            [NSString stringWithFormat:@"{available: %@}", ([self isPrintServiceAvailable] ? @"true" : @"false")]];
    
}

- (void) print:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSUInteger argc = [arguments count];
	
	if (argc < 1) {
		return;	
	}
    self.printHTML = [arguments objectAtIndex:0];
    
    if (argc >= 2){
        self.successCallback = [arguments objectAtIndex:1];
    }
    
    if (argc >= 3){
        self.failCallback = [arguments objectAtIndex:2];
    }
    
    if (argc >= 4){
        self.dialogLeftPos = [[arguments objectAtIndex:3] intValue];
    }
    
    if (argc >= 5){
        self.dialogTopPos = [[arguments objectAtIndex:4] intValue];
    }
    
    [self doPrint];
}

- (void) doPrint{
    
    if (![self isPrintServiceAvailable]){
        [self callbackWithFuntion:self.failCallback withData: @"{success: false, available: false}"];
        return;
    }
    
	if ([UIPrintInteractionController isPrintingAvailable]){
        
        //Get the base URL to be the www directory.
        NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:nil ];
        NSURL *baseURL = [NSURL fileURLWithPath:dbFilePath];
        
		UIWebView *wv = [[UIWebView alloc] init];
        self.webPrintView = wv;
        [wv release];
        self.webPrintView.delegate = self;
        NSString *outString = [self.printHTML stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		[self.webPrintView loadHTMLString:outString baseURL:baseURL];
    }
}

- (void) onPrintingResolved {
    
    if(self.webPrintView) {
        self.webPrintView.delegate = nil;
        self.webPrintView = nil;
    }
}

#pragma mark = UIWebViewDelegate methods

- (void) webViewDidFinishLoad:(UIWebView *)webView  {
    
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (!controller){
        return;
    }    
    
    controller.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    controller.printInfo = printInfo;
    controller.showsPageRange = YES;    
    
    //Get formatter for web (note: margin not required - done in web page)
    UIViewPrintFormatter *viewFormatter = [self.webPrintView viewPrintFormatter];
    viewFormatter.startPage = 0;
    controller.printFormatter = viewFormatter;
    controller.showsPageRange = YES;    
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed || error) {
                [self callbackWithFuntion:self.failCallback withData:
                [NSString stringWithFormat:@"{success: false, available: true, error: \"%@\"}", error.localizedDescription]];
            }
            else {
                [self callbackWithFuntion:self.successCallback withData: @"{success: true, available: true}"];
            }
            
            [self onPrintingResolved];
        };    
    
    /*
     If iPad, and if button offsets passed, then show dilalog originating from offset
     */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        dialogTopPos != 0 && dialogLeftPos != 0) {
        CGRect rect = CGRectMake(dialogLeftPos, dialogTopPos, 1.0, 1.0);
        [controller presentFromRect:rect
                             inView:self.webView 
                           animated:YES 
                  completionHandler:completionHandler];
    } else {
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
}

#pragma mark = UIPrintInteractionControllerDelegate methods

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    
    [self callbackWithFuntion:self.failCallback 
                     withData: [NSString stringWithFormat:@"{success: false, available: true, error: \"canceled\"}"]];
    
    [self onPrintingResolved];
}

-(BOOL) isPrintServiceAvailable{
    
    Class myClass = NSClassFromString(@"UIPrintInteractionController");
    if (myClass) {
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
        return (controller != nil) && [UIPrintInteractionController isPrintingAvailable];
    }
    
    return NO;
}

#pragma mark -
#pragma mark Return messages
                 
-(void) callbackWithFuntion:(NSString *)function withData:(NSString *)value{
    if (!function || [@"" isEqualToString:function]){
        return;
    }
    
    NSString* jsCallBack = [NSString stringWithFormat:@"%@(%@);", function, value];
    [self writeJavascript: jsCallBack];
}

@end
