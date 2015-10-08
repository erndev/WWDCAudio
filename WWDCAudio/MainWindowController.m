//
//  WindowController.m
//  WWDCAudio
//
//  Created by ernesto on 6/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "MainWindowController.h"
#import "SessionListViewController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
  [super windowDidLoad];
  
  [self setupUI];
  
}


-(void)setupUI
{
  self.window.contentViewController = [[SessionListViewController alloc] initWithNibName:NSStringFromClass([SessionListViewController class]) bundle:nil];
}

@end
