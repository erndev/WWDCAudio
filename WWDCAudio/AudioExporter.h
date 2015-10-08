//
//  AudioExporter.h
//  WWDCAudio
//
//  Created by ernesto on 6/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger, AudioExportTaskStatus)
{
  NoTask,
  Running,
  FinishedOK,
  Cancelled,
  Failed
};

typedef void(^AudioExporterCompletionBlock)(NSError *error);

// TODO: Use NSProgress to notifiy the progress of the audio export session.
// TODO: Throttle tasks. Use a queue to limit the numeber of simultaneous export sessions .

@interface AudioExporter : NSObject

@property (nonatomic,readonly) NSError *error;
@property (nonatomic,readonly) AudioExportTaskStatus status;

-(instancetype)initWithVideoURL:(NSURL*)url outputURL:(NSURL*)url;
-(void)startWithCompletionBlock:(AudioExporterCompletionBlock)completionBlock;
-(void)cancel;

@end
