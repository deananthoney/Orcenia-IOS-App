//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//  Copyright 2012, Randy McMillan
// Continued maintainance @RandyMcMillan 2010/2011/2012

#import <UIKit/UIKit.h>

@protocol ChildBrowserDelegate<NSObject>

/*
 *  onChildLocationChanging:newLoc
 *  
 *  Discussion:
 *    Invoked when a new page has loaded
 */
-(void) onChildLocationChange:(NSString*)newLoc;
-(void) onOpenInSafari;
-(void) onClose;
- (void) doCommand:(NSString*)command WithParameters:(NSDictionary*) parameters;
@end


@interface ChildBrowserViewController : UIViewController < UIWebViewDelegate > {
	IBOutlet UIWebView* webView;
    IBOutlet UIBarButtonItem *printButton;
    IBOutlet UIToolbar *toolbar;
	BOOL scaleEnabled;
	BOOL isImage;
	NSString* imageURL;
	NSArray* supportedOrientations;
	id <ChildBrowserDelegate> delegate;
}

@property (nonatomic, retain)id <ChildBrowserDelegate> delegate;
@property (nonatomic, retain) NSArray* supportedOrientations;
@property(retain) NSString* imageURL;
@property(assign) BOOL isImage;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *printButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation; 
- (ChildBrowserViewController*)initWithScale:(BOOL)enabled;
- (void)loadURL:(NSString*)url;
-(void)closeBrowser;

@end
