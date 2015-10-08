//
//  SessionsManager.m
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "SessionsManager.h"
#import "SessionsValueTransformer.h"
#import "Session.h"

NSInteger const kErrorSessionsStillDownloading = -234;
NSString * const kSessionErrorDomain = @"com.cocoawithchurros.wwdcaudio";
NSString * const kWWDCSessionsURL = @"https://devimages.apple.com.edgekey.net/wwdc-services/ftzj8e4h/6rsxhod7fvdtnjnmgsun/videos.json";


@interface SessionsManager()
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSArray *sessionsCache;
@property (nonatomic,strong) NSURLSessionDataTask *dataTask;
@end

@implementation SessionsManager

-(NSURLSession *)session
{
  if( !_session )
  {
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  }
  return _session;
}

-(void)sessionsWithQuery:(NSString*)query completionBlock:(SessionCompletionBlock)completionBlock;
{
  if( self.sessionsCache.count > 0 )
  {
    if (completionBlock) {
      completionBlock([self sessionsWithQuery:query],nil);
    }
  }
  else
  {
      [self downloadSessionsWithCompletionBlock:^(NSArray<Session *> *sessions, NSError *error) {
        
        self.sessionsCache = sessions;
        if( completionBlock )
          completionBlock([self sessionsWithQuery:query], error);
      }];
  }
  
}

-(void)downloadSessionsWithCompletionBlock:(SessionCompletionBlock)completionBlock
{
  
    if( self.dataTask && self.dataTask.state == NSURLSessionTaskStateRunning )
    {
      // return nil. Data not available yet
      NSError *error = [NSError errorWithDomain:kSessionErrorDomain code:kErrorSessionsStillDownloading userInfo:nil];
      if( completionBlock ) completionBlock(nil,error);
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kWWDCSessionsURL]];
        self.dataTask = [self.session dataTaskWithRequest:request  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          NSArray *sessions;
          if( !error  )
          {
            SessionsValueTransformer *transformer = [[SessionsValueTransformer alloc] init];
            sessions = [transformer transformedValue:data];
            self.dataTask = nil;
          }
          if ( completionBlock )
            completionBlock(sessions,error);
          
        }];
      [self.dataTask resume];
    }

}

-(NSArray*)sessionsWithQuery:(NSString*)query
{
  
  NSArray *array = [self.sessionsCache filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Session*  _Nonnull session, NSDictionary<NSString *,id> * _Nullable bindings) {
    return [session containsSearchQuery:query];
  }]];
  return array;
}



@end
