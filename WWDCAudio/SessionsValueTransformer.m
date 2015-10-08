//
//  SessionValueTransformer.m
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "SessionsValueTransformer.h"
#import "Session.h"

NSString * const kSessionsKey= @"sessions";
NSString * const kYearKey= @"year";
NSString * const kTitleKey= @"title";
NSString * const kSessionIDKey= @"sessionID";
NSString * const kDownloadURLKey= @"download_sd";
NSString * const kURLKey= @"url";
NSString * const kDescriptionKey  = @"description";


@implementation SessionsValueTransformer

+(Class)transformedValueClass
{
  return [Session class];
}

+(BOOL)allowsReverseTransformation
{
  return NO;
}

-(id)transformedValue:(NSData*)value
{
 
  if ( ![value isKindOfClass:[NSData class]] || value.length == 0) {
    return nil;
  }
  
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:value options:0 error:nil];
  if( json == nil )
  {
    return nil;
  }
  
  NSArray *jsonSessions = json[kSessionsKey];
  NSMutableArray *sessions = [[NSMutableArray alloc] init];
  for (NSDictionary *jsonSession in jsonSessions )
  {
    Session *session = [self sessionFromJson:jsonSession];
    if( session )
       [sessions addObject:session];
  }
  
  return sessions;
 
}

-(Session*)sessionFromJson:(NSDictionary*)value
{

  
  NSNumber *year = value[kYearKey];
  NSString *title = value[kTitleKey] ;
  NSNumber *sessionID = value[kSessionIDKey];
  NSString *url = value[kDownloadURLKey];
  NSString *info = value[kDescriptionKey];
  
  // video url can be "download_sd" or "url"
  if ( [url isEqual:[NSNull null]] )
  {
    url = value[kURLKey];
  }
  
  if( [url isEqual:[NSNull null]] || [sessionID isEqual:[NSNull null]] || [title isEqual:[NSNull null]] || [info isEqual:[NSNull null]] || [year isEqual:[NSNull null]] )
  {
    return  nil;
  }
  
  NSURL *videoURL = [NSURL URLWithString:url];
  if( videoURL == nil )
  {
    return nil;
  }
  
  return [Session sessionWithId:[sessionID stringValue] title:title year:[year stringValue] info:info videoURL:videoURL];
}

@end
