//
//  NSString+Words.m
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "NSString+Words.h"

@implementation NSString (Words)
-(NSArray*)words
{
  
  NSMutableArray *mutableWords = [NSMutableArray new];
  [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
    if( substring)
    [mutableWords addObject:substring];
    
  }];
  return [mutableWords copy];
}
@end
