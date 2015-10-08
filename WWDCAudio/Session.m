//
//  Session.m
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "Session.h"
#import "NSString+Words.h"

@interface Session()

@property (nonatomic,strong) NSString *sessionID;
@property (nonatomic,strong) NSString *info;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) NSString *year;
@property (nonatomic,strong) NSString *keywords;
@property (nonatomic,strong) NSString *title;
@end

@implementation Session

+(instancetype)sessionWithId:(NSString*)sessionID title:(NSString*)title year:(NSString*)year info:(NSString*)info videoURL:(NSURL*)videoURL
{
  return [[Session alloc] initWithId:sessionID title:title year:year info:info  videoURL:videoURL];
}

-(instancetype)initWithId:(NSString*)sessionID title:(NSString*)title year:(NSString*)year info:(NSString*)info videoURL:(NSURL*)videoURL;
{
  
  self = [super init];
  if( self )
  {
    _sessionID = sessionID;
    _title = title;
    _year = year;
    _info = info;
    _videoURL = videoURL;
    
    [self extractKeyworkds];
  }
  return self;
}

-(void)addKeyWordsFromString:(NSString*)string intoArray:(NSMutableArray*)array
{
 
}

-(void)extractKeyworkds
{
 
  NSMutableString *words = [NSMutableString stringWithString:self.title];
  [words appendFormat:@" %@", self.info ];
  [words appendFormat:@" %@", self.year];
  [words appendFormat:@" %@", self.sessionID];

  self.keywords = [words copy];
}

-(BOOL)containsSearchQuery:(NSString *)query
{
  for( NSString *word in [query words] )
  {
    if( [self.keywords rangeOfString:word options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location == NSNotFound )
    {
        return NO;
    }
  }
  return YES;
}

@end
