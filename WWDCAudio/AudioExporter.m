//
//  AudioExporter.m
//  WWDCAudio
//
//  Created by ernesto on 6/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "AudioExporter.h"

NSString * const kTracksKey = @"tracks";

@interface AudioExporter()

@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) NSURL *outputURL;
@property (nonatomic,strong) NSError *error;
@property (nonatomic) AudioExportTaskStatus status;
@property (nonatomic,strong) AVAssetExportSession *exportSession;
@end

@implementation AudioExporter



-(instancetype)initWithVideoURL:(NSURL*)videoURL outputURL:(NSURL*)outputURL
{
  self = [super init];
  if ( self )
  {
  
    self.videoURL = videoURL;
    self.outputURL = outputURL;
  }
  return self;
}

-(void)cancel
{
  [self.exportSession cancelExport];

}


-(void)exportTrack:(AVAssetTrack*)audioTrack withDuration:(CMTime)duration completionBlock:(AudioExporterCompletionBlock)completionBlock
{
  // Create new composition for the audio track
  NSError *error;
  AVMutableComposition * composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
  [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
  
  if( error != nil )
  {
    [self saveStatus:Failed withError:error];
    if (completionBlock ) completionBlock(error);
    return;
  }
  
  // Export the composition to the output file
  self.exportSession = [[AVAssetExportSession alloc] initWithAsset:composition
                                                        presetName:AVAssetExportPresetAppleM4A];
  self.exportSession.outputURL = self.outputURL;
  self.exportSession.outputFileType = AVFileTypeAppleM4A;
  [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
    
    NSLog(@" %@ ",[self.exportSession.error localizedDescription]);
    NSError *finalError;
    if( self.exportSession.status  == AVAssetExportSessionStatusCancelled )
    {
      finalError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    }
    else
    {
      finalError = self.exportSession.error;
    }
    [self saveStatus:[self statusForAVStatus:self.exportSession.status] withError:finalError];
    
    if( completionBlock ) completionBlock(finalError);
  }];

}

-(void)saveStatus:(AudioExportTaskStatus)status withError:(NSError*)error
{
  self.status = status;
  self.error = error;
}

-(AudioExportTaskStatus)statusForAVStatus:(AVAssetExportSessionStatus)sessionStatus
{
  AudioExportTaskStatus status = NoTask;
  
  switch (sessionStatus ) {
    case AVAssetExportSessionStatusUnknown:
      break;
    case AVAssetExportSessionStatusWaiting:
    case AVAssetExportSessionStatusExporting:
      status = Running;
      break;
    case AVAssetExportSessionStatusCompleted:
      status = FinishedOK;
      break;
    case AVAssetExportSessionStatusCancelled:
      status = Cancelled;
      break;
    case AVAssetExportSessionStatusFailed:
      status = Failed;
    default:
      break;
  }
  return status;
}

-(void)startWithCompletionBlock:(AudioExporterCompletionBlock)completionBlock;
{
  
  [self saveStatus:Running withError:nil];
  
  AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
  self.status = Running;
  [videoAsset loadValuesAsynchronouslyForKeys:@[kTracksKey] completionHandler:^{
    
    NSLog(@"Tracks read");
    NSError *tracksError;
    BOOL tracksOK = [videoAsset statusOfValueForKey:kTracksKey error:&tracksError] == AVKeyValueStatusLoaded;
    if(!tracksOK )
    {
      [self saveStatus:Failed withError:tracksError];
      if( completionBlock) completionBlock(tracksError);
      return;
    }
    // Read the tracks and create a export session
    AVAssetTrack *audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    [self exportTrack:audioTrack withDuration:videoAsset.duration completionBlock:completionBlock];
  }];

}



@end
