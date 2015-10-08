//
//  AppDelegate.m
//  WWDCAudio
//
//  Created by ernesto on 6/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()<NSUserNotificationCenterDelegate>


@property (strong) MainWindowController *windowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  self.windowController = [[MainWindowController alloc] initWithWindowNibName:NSStringFromClass([MainWindowController class]) ];
  [self.windowController showWindow:self];
  
  // MAke sure the notifications are allways shown for this app
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
  return YES;
}

@end
