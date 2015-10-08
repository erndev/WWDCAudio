//
//  AudioExportManager.h
//  WWDCAudio
//
//  Created by ernesto on 8/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioExporter.h"

typedef void(^AudioExportCompletionBlock)(NSError *error );


@interface AudioExportManager : NSObject

-(BOOL)startTaskWithVideoURL:(NSURL*)videoURL outputURL:(NSURL*)url completionBlock:(AudioExportCompletionBlock)completionBlock;
-(void)stopTaskWithVideoURL:(NSURL*)url;
-(AudioExportTaskStatus)statusForTaskWithVideoURL:(NSURL*)url;
@end
