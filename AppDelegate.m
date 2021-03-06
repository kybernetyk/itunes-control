//
//  AppDelegate.m
//  itunes control
//
//  Created by Jaroslaw Szpilewski on 07.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <EyeTunes/EyeTunes.h>

@implementation AppDelegate

#pragma mark -
#pragma mark iTunes Controll Methods

// mute/unmute
- (void) toggleMute
{
	if (isMuted == YES)
	{
		isMuted = NO;
		
		[[EyeTunes sharedInstance] setPlayerVolume: previousVolume];
		
	}
	else
	{
		isMuted = YES;
		
		previousVolume = [[EyeTunes sharedInstance] playerVolume];
		[[EyeTunes sharedInstance] setPlayerVolume: 0];
	}
}


/*
 wrapper functions for EyeTunes messages
*/
- (void) increaseVolume
{
	[[EyeTunes sharedInstance] setPlayerVolume: [[EyeTunes sharedInstance] playerVolume] + 10];
}

- (void) decreaseVolume
{
	[[EyeTunes sharedInstance] setPlayerVolume: [[EyeTunes sharedInstance] playerVolume] - 10];	
}

- (void) startPlayback
{
	[[EyeTunes sharedInstance] play];	
}

- (void) stopPlayback
{
	[[EyeTunes sharedInstance] stop];
}

- (void) pausePlayback
{
	[[EyeTunes sharedInstance] pause];
}

- (void) nextTrack
{
	[[EyeTunes sharedInstance] nextTrack];
}

-(void) previousTrack
{
	[[EyeTunes sharedInstance] previousTrack];
}



#pragma mark -
#pragma mark public IB accessable methods

// starts the poll Timer that will fetch new commands every 1.0 secs
- (IBAction) startPolling: (id) sender
{
	isMuted = NO;
	isPolling = NO;
	
	pollTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
												  target: self
												selector: @selector(handlePollTimer:)
												userInfo: nil
												repeats: YES];

	[pollTimer retain]; //timer could get autoreleased anytime
}


// stops the poll timer
- (IBAction) stopPolling: (id) sender
{
	[pollTimer invalidate];
	[pollTimer release];
}

//quits the application if chosen from the status menu 
- (IBAction) quitAppByMenu : (id) sender
{
	[NSApp terminate: self];
}


#pragma mark -
#pragma mark private methods


// creates a menu item in the status menu
- (void) createStatusItem
{
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"menu title"] autorelease];
	
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(openPreferences:) keyEquivalent:[NSString string]] autorelease];
	[menu addItem: menuItem];
	[menu addItem:[NSMenuItem separatorItem]];
	
	[menu addItemWithTitle:@"Quit" action:@selector(quitAppByMenu:) keyEquivalent:[NSString string]];
	
	
	
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	
	statusItem = [statusBar statusItemWithLength: NSVariableStatusItemLength];
	[statusItem setTitle:@"♫ ..."];
	[statusItem setEnabled: YES];
	[statusItem setHighlightMode: YES];
	[statusItem setMenu: menu];
	
	[statusItem retain];
	
}

// the remote point where we can poll our messages
// make this a preference setting
#define POLL_MESSAGE_REMOTE_URL "http://localhost:8888/control/poll_message.php"

// the timer's main loop. fetches command from server and processes it
- (void) handlePollTimer: (NSTimer *) timer
{
	//work against lag.
	//if isPolling == TRUE don't poll for new message
	if (isPolling == YES)
	{	
		NSLog(@"isPolling = YES!!!");
		return;
	}
	
	//ok, we're polling now
	isPolling = YES;
	
	NSURL *url = [NSURL URLWithString:@POLL_MESSAGE_REMOTE_URL];
	NSString *commandString = [NSString stringWithContentsOfURL: url];

	[self processCommandString: commandString];

	isPolling = NO;
}

//processes the received commandString
- (void) processCommandString: (NSString *) commandString
{
	commandString = [commandString lowercaseString];
	
	if ([commandString isEqualToString: @"none"])
	{
		return;
	}
	
	//if (commandString)
	//	[statusItem setTitle: commandString];
	
	ETTrack *currentTrack = [[EyeTunes sharedInstance] currentTrack];
	
	NSString *displayString = [NSString stringWithFormat:@"♫ %@ - %@", [currentTrack artist], [currentTrack name]];
	
	[statusItem setTitle: displayString];

	
	
	//don't spam log with "none" :)
	NSLog(@"chosing action for: %@",commandString);	

	if ([commandString isEqualToString: @"stop"])
	{
		[self stopPlayback];
		return;
	}

	if ([commandString isEqualToString: @"pause"])
	{
		[self pausePlayback];
		return;
	}
	
	if ([commandString isEqualToString: @"play"])
	{
		[self startPlayback];
		return;
	}
	
	if ([commandString isEqualToString: @"next"])
	{
		[self nextTrack];
		return;
	}
	
	if ([commandString isEqualToString: @"prev"])
	{
		[self previousTrack];
		return;
	}
	
	if ([commandString isEqualToString: @"vol_dec"])
	{
		[self decreaseVolume];
		return;
	}
	
	if ([commandString isEqualToString: @"vol_inc"])
	{
		[self increaseVolume];
		return;
	}
	
	if ([commandString isEqualToString: @"mute_unmute"])
	{
		[self toggleMute];
		return;
	}
	
}



#pragma mark -
#pragma mark Application Delegate Methods

// called by cocoa when our app is loaded and ready to run
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//create the status menu item
	[self createStatusItem];
	
	//starts the poll timer that will fetch new commands every 1.0 secs
	[self startPolling: self];
	
}


@end
