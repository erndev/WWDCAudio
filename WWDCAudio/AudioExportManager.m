//
//  AudioExportManager.m
//  WWDCAudio
//
//  Created by ernesto on 8/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "AudioExportManager.h"
#import "AudioExporter.h"


#pragma mark - AudioExportManager
@interface AudioExportManager()
@property (nonatomic,strong) NSMutableDictionary *tasks;

@end

@implementation AudioExportManager

-(instancetype)init
{
  self = [super init];
  if (self )
  {
    _tasks = [NSMutableDictionary new];
  }
  return self;
}

-(BOOL)startTaskWithVideoURL:(NSURL *)videoURL outputURL:(NSURL *)outputURL completionBlock:(AudioExportCompletionBlock)completionBlock
{
  if( videoURL == nil || outputURL == nil )
  {
    return NO;
  }
  
  AudioExporter *exporter = [[AudioExporter alloc] initWithVideoURL:videoURL outputURL:outputURL];
  
  [exporter startWithCompletionBlock:^(NSError *error) {
    NSLog( @"AudioExport manager. Exporter finished with error: %@", error);
      if( completionBlock)
        completionBlock(error);
  }];
  
  self.tasks[videoURL] = exporter;
  return YES;

}

-(void)stopTaskWithVideoURL:(NSURL*)url
{
  AudioExporter *exporter = self.tasks[url];
  [exporter cancel];
  [self.tasks removeObjectForKey:url];
}


-(AudioExportTaskStatus)statusForTaskWithVideoURL:(NSURL*)url
{
  AudioExportTaskStatus status = NoTask;
  AudioExporter *exporter = self.tasks[url];
  if( exporter != nil )
  {
    status = exporter.status;
  }
  return status ;

}


@end
