//
//  main.m
//  itunes control
//
//  Created by Jaroslaw Szpilewski on 07.12.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EyeTunes/EyeTunes.h>

int main(int argc, char *argv[])
{
	EyeTunes *e = [EyeTunes sharedInstance];
	[e setPlayerVolume: 0];
	
	return NSApplicationMain(argc,  (const char **) argv);
}