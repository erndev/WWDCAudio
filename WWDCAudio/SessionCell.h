//
//  SessionCell.h
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SessionCell : NSTableCellView
@property (nonatomic,strong) IBOutlet NSTextField *infoTextField;
@property (nonatomic,strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic,strong) IBOutlet NSButton *button;
@end
